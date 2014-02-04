#!/bin/bash

export PG_SERVER_VERSION="9.3" # 8.4, 9.0, 9.1, 9.2, 9.3
export PG_SERVER_EXTENSIONS="btree_gin btree_gist fuzzystrmatch hstore intarray ltree pg_trgm tsearch2 unaccent" # see: http://www.postgresql.org/docs/9.3/static/contrib.html
export PG_SERVER_CONFIG_FILE="/etc/postgresql/$PG_SERVER_VERSION/main/postgresql.conf"
export PG_SERVER_HBA_FILE="/etc/postgresql/$PG_SERVER_VERSION/main/pg_hba.conf"
export PG_SERVER_TUNE_VERSION="0.9.3"
export PG_SERVER_TUNE_URL="http://pgfoundry.org/frs/download.php/2449/pgtune-$PG_SERVER_TUNE_VERSION.tar.gz"
export PG_SERVER_USER="postgres"
export PG_SERVER_BIND_IP=""
export PG_SERVER_TRUST_IPS=""

function pg-server-install-packages {
  announce "Install PosgreSQL Server $PG_SERVER_VERSION"
  install-packages postgresql-$PG_SERVER_VERSION libpq-dev postgresql-contrib-$PG_SERVER_VERSION
}

function pg-server-tune {
  local tmpdir=$(cd-tmp)

  announce "Tune PostgreSQL $PG_SERVER_VERSION"
  download $PG_SERVER_TUNE_URL
  extract pgtune-$PG_SERVER_TUNE_VERSION.tar.gz

  ./pgtune-$PG_SERVER_TUNE_VERSION/pgtune -i $PG_SERVER_CONFIG_FILE -o $PG_SERVER_CONFIG_FILE.pgtune
  mv $PG_SERVER_CONFIG_FILE $PG_SERVER_CONFIG_FILE.original
  mv $PG_SERVER_CONFIG_FILE.pgtune $PG_SERVER_CONFIG_FILE
  chown $PG_SERVER_USER:$PG_SERVER_USER $PG_SERVER_CONFIG_FILE

  cd ~/
  rm -rf $tmpdir
}

function pg-server-bind-ip {
  if [ -z $PG_SERVER_BIND_IP ]; then
    return 0
  fi

  announce "Bind PostgreSQL database server to local network interface"
  tee -a $PG_SERVER_CONFIG_FILE <<EOT
listen_addresses = 'localhost,$PG_SERVER_BIND_IP'
EOT
}

function pg-server-trust-ips {
  if [ -z "$PG_SERVER_TRUST_IPS" ]; then
    return 0
  fi

  announce "Whitelist incoming connections for:"
  # hba format: TYPE DBNAME USER ADDR AUTH
  for trust_ip in $PG_SERVER_TRUST_IPS; do
    announce-item "$trust_ip"
    tee -a $PG_SERVER_HBA_FILE <<EOT
host all all $trust_ip trust
EOT
  done
}

# $1 db user name
function pg-server-create-user {
  announce "Create database user: $1"
  su - $PG_SERVER_USER -c "createuser -D -R $1"
}

# $1 db user name
# $2 db name
function pg-server-create-db {
  announce "Create database: $2"
  su - $PG_SERVER_USER -c "createdb -O $1 $2"

  for extension in $PG_SERVER_EXTENSIONS; do
    announce "Add extension: $extension"
    su - $PG_SERVER_USER -c "psql -d $2 -c \"CREATE EXTENSION IF NOT EXISTS $extension;\""
  done
}

function provision-pg-server {
  section "PostgreSQL Server"
  pg-add-sources
  pg-server-install-packages
  pg-server-tune
  pg-server-bind-ip
  pg-server-trust-ips
}
