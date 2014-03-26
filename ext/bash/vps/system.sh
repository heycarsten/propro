#!/usr/bin/env bash
export VPS_SYSTEM_HOSTNAME="" # @require
export VPS_SYSTEM_FQDN="" # @require
export VPS_SYSTEM_ADMIN_AUTHORIZED_GITHUB_USERS="" # @require
export VPS_SYSTEM_ADMIN_SUDO_PASSWORD="" # @require
export VPS_SYSTEM_PRIVATE_IP="" # @specify
export VPS_SYSTEM_DNS_SERVERS="208.67.222.222 208.67.220.220" # Only used if private IP is specified
export VPS_SYSTEM_ADMIN_USER="admin" # @specify
export VPS_SYSTEM_PRIVATE_NETMASK="255.255.128.0"
export VPS_SYSTEM_ALLOW_PORTS="www 443 ssh"
export VPS_SYSTEM_LIMIT_PORTS="ssh"
export VPS_SYSTEM_ALLOW_PRIVATE_IPS="" # @specify
export VPS_SYSTEM_ALLOW_PRIVATE_PORTS="5432 6379" # Postgres & Redis
export VPS_SYSTEM_GET_PUBLIC_IP_SERVICE_URL="http://ipecho.net/plain"

function get-vps-system-public-ip {
  wget -qO- $VPS_SYSTEM_GET_PUBLIC_IP_SERVICE_URL
}

function get-vps-system-default-gateway {
  ip route | awk '/default/ { print $3 }'
}

function vps-system-configure-hostname {
  announce "Set hostname to $VPS_SYSTEM_HOSTNAME"
  set-hostname $VPS_SYSTEM_HOSTNAME
}

function vps-system-configure-sshd {
  announce "Configure sshd:"
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

  announce "Restart sshd"
  service ssh restart
}

function vps-system-configure-firewall {
  section "Firewall"
  install-packages ufw

  announce "Configuring firewall:"
  ufw default deny
  ufw logging on

  for port in $VPS_SYSTEM_ALLOW_PORTS; do
    announce-item "allow $port"
    ufw allow $port
  done

  for port in $VPS_SYSTEM_LIMIT_PORTS; do
    announce-item "limit $port"
    ufw limit $port
  done

  for local_ip in $VPS_SYSTEM_ALLOW_PRIVATE_IPS; do
    for port in $VPS_SYSTEM_ALLOW_PRIVATE_PORTS; do
      announce-item "allow $port from $local_ip"
      ufw allow $port from $local_ip
    done
  done

  echo 'y' | ufw enable
}

function vps-system-configure-admin-user {
  announce "Adding admin user: $VPS_SYSTEM_ADMIN_USER"
  add-user $VPS_SYSTEM_ADMIN_USER sudo $VPS_SYSTEM_ADMIN_SUDO_PASSWORD
  add-pubkeys-from-github $VPS_SYSTEM_ADMIN_USER "$VPS_SYSTEM_ADMIN_AUTHORIZED_GITHUB_USERS"
}

function vps-system-configure-interfaces {
  announce "Resolving extenal IP address"

  local ip_addr=$(get-vps-system-public-ip)
  local gateway=$(get-vps-system-default-gateway)
  local fqdn="$ip_addr $VPS_SYSTEM_HOSTNAME $VPS_SYSTEM_FQDN"

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

  if [ $VPS_SYSTEM_PRIVATE_IP ]; then
    tee -a /etc/network/interfaces <<EOT

# DNS Servers
dns-nameservers $VPS_SYSTEM_DNS_SERVERS

# Private interface
iface eth0:1 inet static
 address $VPS_SYSTEM_PRIVATE_IP
 netmask $VPS_SYSTEM_PRIVATE_NETMASK
EOT
  fi

  announce "Restart networking"
  service networking stop && service networking start

  announce "Removing DHCP"
  aptitude -q -y remove isc-dhcp-client dhcp3-client dhcpcd
}

function provision-vps-system {
  section "VPS System"
  system-upgrade
  system-configure-timezone
  vps-system-configure-hostname
  system-configure-locale
  system-install-packages
  system-configure-shared-memory
  system-install-sources
  vps-system-configure-admin-user
  vps-system-configure-interfaces
  vps-system-configure-sshd
  vps-system-configure-firewall
}
