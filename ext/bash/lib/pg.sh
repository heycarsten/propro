#!/usr/bin/env bash
export PG_VERSION="9.3" # @specify
export PG_EXTENSIONS="btree_gin btree_gist fuzzystrmatch hstore intarray ltree pg_trgm tsearch2 unaccent" # @specify see: http://www.postgresql.org/docs/9.3/static/contrib.html
export PG_CONFIG_FILE="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
export PG_HBA_FILE="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
export PG_TUNE_VERSION="0.9.3"
export PG_TUNE_URL="http://pgfoundry.org/frs/download.php/2449/pgtune-$PG_TUNE_VERSION.tar.gz"
export PG_USER="postgres"

function pg-install-packages {
  install-packages postgresql-$PG_VERSION libpq-dev postgresql-contrib-$PG_VERSION
}

function pg-tune {
  local tmpdir=$(get-tmp-dir)
  cd "$tmpdir"

  announce "Tune PostgreSQL $PG_VERSION"
  download $PG_TUNE_URL
  extract pgtune-$PG_TUNE_VERSION.tar.gz

  ./pgtune-$PG_TUNE_VERSION/pgtune -i $PG_CONFIG_FILE -o $PG_CONFIG_FILE.pgtune
  mv $PG_CONFIG_FILE $PG_CONFIG_FILE.original
  mv $PG_CONFIG_FILE.pgtune $PG_CONFIG_FILE
  chown $PG_USER:$PG_USER $PG_CONFIG_FILE

  cd ~/
  rm -rf "$tmpdir"
}

# $1 db user name
# $2 db name
function pg-createdb {
  announce "Create database: $2"
  su - $PG_USER -c "createdb -O $1 $2"

  if [ $PG_EXTENSIONS ]; then
    announce "Add extensions:"
    for extension in $PG_EXTENSIONS; do
      announce-item "$extension"
      su - $PG_USER -c "psql -d $2 -c \"CREATE EXTENSION IF NOT EXISTS $extension;\""
    done
  fi
}
