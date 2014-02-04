#!/usr/bin/env bash

export DB_PG_VERSION="9.3" # 8.4, 9.0, 9.1, 9.2, 9.3
export DB_PG_EXTENSIONS="btree_gin btree_gist fuzzystrmatch hstore intarray ltree pg_trgm tsearch2 unaccent" # see: http://www.postgresql.org/docs/9.3/static/contrib.html
export DB_PG_CONFIG_FILE="/etc/postgresql/$DB_PG_VERSION/main/postgresql.conf"
export DB_PG_HBA_FILE="/etc/postgresql/$DB_PG_VERSION/main/pg_hba.conf"
export DB_PG_TUNE_VERSION="0.9.3"
export DB_PG_TUNE_URL="http://pgfoundry.org/frs/download.php/2449/pgtune-$DB_PG_TUNE_VERSION.tar.gz"
export DB_PG_USER="postgres"
export DB_PG_BIND_IP=""
export DB_PG_TRUST_IPS=""

function db-pg-install-packages {
  announce "Install PosgreSQL Server $DB_PG_VERSION"
  install-packages postgresql-$DB_PG_VERSION libpq-dev postgresql-contrib-$DB_PG_VERSION
}

function db-pg-tune {
  local tmpdir=$(cd-tmp)

  announce "Tune PostgreSQL $DB_PG_VERSION"
  download $DB_PG_TUNE_URL
  extract pgtune-$DB_PG_TUNE_VERSION.tar.gz

  ./pgtune-$DB_PG_TUNE_VERSION/pgtune -i $DB_PG_CONFIG_FILE -o $DB_PG_CONFIG_FILE.pgtune
  mv $DB_PG_CONFIG_FILE $DB_PG_CONFIG_FILE.original
  mv $DB_PG_CONFIG_FILE.pgtune $DB_PG_CONFIG_FILE
  chown $DB_PG_USER:$DB_PG_USER $DB_PG_CONFIG_FILE

  cd ~/
  rm -rf $tmpdir
}

function db-pg-bind-ip {
  if [ -z $DB_PG_BIND_IP ]; then
    return 0
  fi

  announce "Bind PostgreSQL database server to local network interface"
  tee -a $DB_PG_CONFIG_FILE <<EOT
listen_addresses = 'localhost,$DB_PG_BIND_IP'
EOT
}

function db-pg-trust-ips {
  if [ -z "$DB_PG_TRUST_IPS" ]; then
    return 0
  fi

  announce "Whitelist incoming connections for:"
  # hba format: TYPE DBNAME USER ADDR AUTH
  for trust_ip in $DB_PG_TRUST_IPS; do
    announce-item "$trust_ip"
    tee -a $DB_PG_HBA_FILE <<EOT
host all all $trust_ip trust
EOT
  done
}

# $1 db user name
function db-pg-create-user {
  announce "Create database user: $1"
  su - $DB_PG_USER -c "createuser -D -R $1"
}

# $1 db user name
# $2 db name
function db-pg-create-db {
  announce "Create database: $2"
  su - $DB_PG_USER -c "createdb -O $1 $2"

  for extension in $DB_PG_EXTENSIONS; do
    announce "Add extension: $extension"
    su - $DB_PG_USER -c "psql -d $2 -c \"CREATE EXTENSION IF NOT EXISTS $extension;\""
  done
}

function provision-db-pg {
  section "PostgreSQL Server"
  db-pg-install-packages
  db-pg-tune
  db-pg-bind-ip
  db-pg-trust-ips
}
