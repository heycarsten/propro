#!/usr/bin/env bash
export SYSTEM_SOURCES_PG_KEY_URL="http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc"

function system-source-add-pg {
  announce "Add PostgreSQL sources:"
  tee /etc/apt/sources.list.d/pgdg.list <<EOT
deb http://apt.postgresql.org/pub/repos/apt/ $(release-codename)-pgdg main
EOT

  announce-item "apt.postgresql.org"
  add-source-key $SYSTEM_SOURCES_PG_KEY_URL
  update-sources
}

function system-sources-install {
  section "Package Sources"
  system-source-add-pg
}
