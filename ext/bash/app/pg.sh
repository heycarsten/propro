#!/usr/bin/env bash
function provision-app-pg {
  section "PostgreSQL Client"
  install-packages libpq-dev
  install-packages postgresql-client-$PG_VERSION
}
