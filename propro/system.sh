#!/bin/bash

export SYSTEM_HOSTNAME="" # required
export SYSTEM_FQDN="" # required
export SYSTEM_ADMIN_AUTHORIZED_GITHUB_USERS="" # required
export SYSTEM_ADMIN_SUDO_PASSWORD="" # required
export SYSTEM_PRIVATE_IP=""
export SYSTEM_ADMIN_USER="admin"
export SYSTEM_SHMALL_PERCENT="0.75"
export SYSTEM_SHMMAX_PERCENT="0.5"
export SYSTEM_PRIVATE_NETMASK="255.255.128.0"
export SYSTEM_BASE_PACKAGES="curl vim-nox less htop build-essential openssl"
export SYSTEM_TIMEZONE="Etc/UTC"
export SYSTEM_LOCALE="en_US.UTF-8"
export SYSTEM_ALLOW_PORTS="www 443 ssh"
export SYSTEM_LIMIT_PORTS="ssh"
export SYSTEM_ALLOW_PRIVATE_IPS=""
export SYSTEM_ALLOW_PRIVATE_PORTS="5432 6379" # Postgres & Redis

function system-configure-shared-memory {
  announce "Configuring shared memory"
  install-packages bc

  local shmall=$(get-kernel-shmall $SYSTEM_SHMALL_PERCENT)
  local shmmax=$(get-kernel-shmmax $SYSTEM_SHMMAX_PERCENT)

  sysctl -w kernel.shmall=$shmall
  sysctl -w kernel.shmmax=$shmmax
  tee -a /etc/sysctl.conf <<EOT

kernel.shmall = $shmall
kernel.shmmax = $shmmax
EOT
}

function system-configure-admin-user {
  announce "Adding admin user: $SYSTEM_ADMIN_USER"
  add-user $SYSTEM_ADMIN_USER sudo $SYSTEM_ADMIN_SUDO_PASSWORD
  add-pubkeys-from-github $SYSTEM_ADMIN_USER $SYSTEM_ADMIN_AUTHORIZED_GITHUB_USERS
}

function system-configure-interfaces {
  announce "Resolving extenal IP address"

  local ip_addr=$(get-public-ip)
  local gateway=$(get-default-gateway)
  local fqdn="$ip_addr $SYSTEM_HOSTNAME $SYSTEM_FQDN"

  announce "Setting FQDN: $fqdn"
  echo "$fqdn" >> /etc/hosts

  announce "Writing /etc/network/interfaces"
  tee /etc/network/interfaces <<EOT
auto lo
iface lo inet loopback

auto eth0 eth0:0 eth0:1

# Public interface
iface eth0 inet static
 address $ip_addr
 netmask 255.255.255.0
 gateway $gateway
EOT

  if [ $SYSTEM_PRIVATE_IP ]; then
    tee -a /etc/network/interfaces <<EOT

# Private interface
iface eth0:1 inet static
 address $SYSTEM_PRIVATE_IP
 netmask $SYSTEM_PRIVATE_NETMASK
EOT
  fi

  announce "Restart networking"
  /etc/init.d/networking restart

  announce "Removing DHCP"
  aptitude -q -y remove isc-dhcp-client dhcp3-client dhcpcd
}

function system-install-packages {
  announce "Install base packages"
  install-packages $SYSTEM_BASE_PACKAGES
}

function system-configure-timezone {
  announce "Set timezone to $SYSTEM_TIMEZONE"
  set-timezone $SYSTEM_TIMEZONE
}

function system-configure-locale {
  announce "Set locale to $SYSTEM_LOCALE"
  set-locale $SYSTEM_LOCALE
}

function system-configure-hostname {
  announce "Set hostname to $SYSTEM_HOSTNAME"
  set-hostname $SYSTEM_HOSTNAME
}

function system-upgrade {
  announce "Update and upgrade packages"
  upgrade-system
}

function system-configure-sshd {
  announce "Configure sshd"
  announce-item "disable root login"
  announce-item "disable password auth"
  tee /etc/ssh/sshd_config <<EOT
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
UsePrivilegeSeparation yes
KeyRegenerationInterval 3600
ServerKeyBits 768
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin no
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication no
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
EOT

  announce "restart sshd"
  service ssh restart
}

function system-configure-firewall {
  section "Firewall"
  install-packages ufw

  announce "Configuring firewall"
  ufw default deny
  ufw logging on

  for port in $SYSTEM_ALLOW_PORTS; do
    announce-item "allow $port"
    ufw allow $port
  done

  for port in $SYSTEM_LIMIT_PORTS; do
    announce-item "limit $port"
    ufw limit $port
  done

  for local_ip in $SYSTEM_ALLOW_PRIVATE_IPS; do
    for port in $SYSTEM_ALLOW_PRIVATE_PORTS; do
      announce-item "allow $port from $local_ip"
      ufw allow $port from $local_ip
    done
  done

  ufw enable
}

function provision-system {
  section "System"

  system-upgrade
  system-configure-timezone
  system-configure-locale
  system-configure-hostname
  system-install-packages
  system-configure-shared-memory
  system-configure-admin-user
  system-configure-interfaces
  system-configure-sshd
  system-configure-firewall
}
