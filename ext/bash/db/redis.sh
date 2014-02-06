#!/usr/bin/env bash
export DB_REDIS_BIND_IP="" # @specify

# $1 ip (private IP of server)
function redis-bind-ip {
  if [ ! $DB_REDIS_BIND_IP ]; then
    return 0
  fi

  announce "Bind Redis to local network interface"
  tee -a $REDIS_CONF_FILE <<EOT
bind $DB_REDIS_BIND_IP
EOT
}

function provision-db-redis {
  section "Redis"
  redis-install
  redis-bind-ip
}
