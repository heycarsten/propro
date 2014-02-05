#!/usr/bin/env bash
export DB_NAME="" # @require
export DB_USER="" # @require
export DB_BIND_IP="" # @specify Bind Postgres to specific interface
export DB_TRUST_IPS="" # @specify Private network IPs allowed to connect to Postgres

function db-bind-ip {
  if [ -z $DB_BIND_IP ]; then
    return 0
  fi

  announce "Bind PostgreSQL to $DB_BIND_IP"
  tee -a $PG_CONFIG_FILE <<EOT
listen_addresses = 'localhost,$DB_BIND_IP'
EOT
}

function db-trust-ips {
  if [ -z "$DB_TRUST_IPS" ]; then
    return 0
  fi

  announce "Allow private network connections from:"
  # hba format: TYPE DBNAME USER ADDR AUTH
  for trust_ip in $DB_TRUST_IPS; do
    announce-item "$trust_ip"
    tee -a $PG_HBA_FILE <<EOT
host all all $trust_ip trust
EOT
  done
}
# $1 db user name
function db-create-user {
  announce "Create database user: $1"
  su - $PG_USER -c "createuser -D -R $1"
}

function provision-db {
  provision-pg
  db-bind-ip
  db-trust-ips
  db-create-user $DB_USER
  pg-createdb $DB_USER $DB_NAME
}
