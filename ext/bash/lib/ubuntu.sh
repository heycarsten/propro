#!/usr/bin/env bash
function get-processor-count {
  nproc
}

function release-codename {
  lsb_release -c -s
}

# $@ package names
function install-packages {
  announce "Installing packages:"
  for package in $@; do
    announce-item "$package"
  done
  aptitude -q -y -o Dpkg::Options::="--force-confnew" install $@
}

function get-archtype {
  if [ $(getconf LONG_BIT) == 32 ]; then
    echo 'x86'
  else
    echo 'x64'
  fi
}

function update-sources {
  apt-get -qq -y update
}

# $1 unix user
# $2 service name
# $3 service args
function add-sudoers-entries {
  for event in start status stop reload restart; do
    if [ $3 ]; then
      tee -a /etc/sudoers.d/$2.entries <<EOT
$1 ALL=NOPASSWD: /sbin/$event $2 $3
EOT
    else
      tee -a /etc/sudoers.d/$2.entries <<EOT
$1 ALL=NOPASSWD: /sbin/$event $2
EOT
    fi
  done
}

function reboot-system {
  shutdown -r now
}

# $1 package name
function reconfigure-package {
  dpkg-reconfigure -f noninteractive $1
}

# $1 key URL
function add-source-key {
  wget --quiet -O - $1 | apt-key add -
}

# $@ files to extract
function extract {
  tar xzf $@
}

# $1 URL to download
function download {
  wget -nv $1
}

function get-ram-bytes {
  free -m -b | awk '/^Mem:/{print $2}'
}

function get-page-size {
  getconf PAGE_SIZE
}

function get-ram-pages {
  echo "$(get-ram-bytes) / $(get-page-size)" | bc
}

# $1 shmall percent
function get-kernel-shmall {
  echo "($(get-ram-pages) * $1) / 1" | bc
}

# $1 shmmax percent
function get-kernel-shmmax {
  echo "($(get-ram-bytes) * $1) / 1" | bc
}

# $1 unix user
# $2 path
function as-user-mkdir {
  mkdir -p $2
  chown $1:$1 $2
}

function upgrade-system {
  update-sources
  apt-get -qq -y install aptitude
  aptitude -q -y -o Dpkg::Options::="--force-confnew" full-upgrade
}

# $1 timezone
function set-timezone {
  echo $1 > /etc/timezone
  reconfigure-package tzdata
}

# $1 locale eg: en_US.UTF-8
function set-locale {
  export LANGUAGE=$1
  export LANG=$1
  export LC_ALL=$1
  locale-gen $1
  reconfigure-package locales
  update-locale
}

# $1 hostname
function set-hostname {
  echo $1 > /etc/hostname
  hostname -F /etc/hostname
}

# $1 unix user
# $2 unix group
# $3 password
function add-user {
  if [ $2 ]; then
    announce "Adding $1 user to group $2"
    useradd -m -s /bin/bash -g $2 $1
  else
    announce "Adding $1 user"
    useradd -m -s /bin/bash $1
  fi

  if [ $3 ]; then
    announce "Setting password for $1 user"
    echo "$1:$3" | chpasswd
  fi
}

# $1 unix user
# $2 github usernames for public keys
function add-pubkeys-from-github {
  announce "Installing public keys for $1 from GitHub users:"

  local ssh_dir="/home/$1/.ssh"
  local keys_file="$ssh_dir/authorized_keys"

  mkdir -p $ssh_dir
  touch $keys_file

  for user in $2; do
    announce-item "$user"
    local url="https://github.com/$user.keys"
    tee -a $keys_file <<EOT
# $url
$(wget -qO- $url)

EOT
  done

  chmod 700 $ssh_dir
  chmod 600 $keys_file
  chown -R $1 $ssh_dir
}
