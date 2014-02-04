#!/bin/bash

export PG_APT_SOURCE_KEY_URL="http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc"

function pg-add-sources {
  announce "Add PostgreSQL sources"
  tee /etc/apt/sources.list.d/pgdg.list <<EOT
deb http://apt.postgresql.org/pub/repos/apt/ $(release-codename)-pgdg main
EOT

  announce "Add apt.postgresql.org key"
  add-source-key $PG_APT_SOURCE_KEY_URL

  announce "Update sources"
  update-sources
}
