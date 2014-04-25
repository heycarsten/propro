#!/usr/bin/env bash
export REDIS_VERSION="2.8.7" # @specify
export REDIS_USER="redis"
export REDIS_CONF_FILE="/etc/redis.conf"
export REDIS_DATA_DIR="/var/lib/redis"
export REDIS_FORCE_64BIT="no" # @specify Force 64bit build even if available memory is lte 4GiB

function get-redis-url {
  echo "http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz"
}

function redis-install {
  local tmpdir=$(get-tmp-dir)
  cd "$tmpdir"

  announce "Download $REDIS_VERSION"
  download $(get-redis-url)

  announce "Extract"
  extract redis-$REDIS_VERSION.tar.gz
  cd redis-$REDIS_VERSION

  if [ $(get-ram-bytes) -gt 4294967296 ] || is-yes $REDIS_FORCE_64BIT; then
    announce "Compile"
    make
  else
    announce "Compile (32bit, available memory <= 4GiB)"
    install-packages libc6-dev-i386
    make 32bit
  fi

  announce "Install $REDIS_VERSION"
  make install

  announce "Add Redis user: $REDIS_USER"
  useradd -r $REDIS_USER

  announce "Create Redis directories"
  as-user-mkdir $REDIS_USER $REDIS_DATA_DIR

  announce "Copy Redis config to $REDIS_CONF_FILE"
  cp ./redis.conf $REDIS_CONF_FILE

  cd ~/
  rm -rf "$tmpdir"

  announce "Update Redis config"
  tee -a $REDIS_CONF_FILE <<EOT
syslog-enabled yes
syslog-ident redis
dir $REDIS_DATA_DIR
EOT

  announce "Create upstart for Redis"
  tee /etc/init/redis.conf <<EOT
description "Redis"
start on runlevel [23]
stop on shutdown
exec sudo -u $REDIS_USER /usr/local/bin/redis-server $REDIS_CONF_FILE
respawn
EOT
}
