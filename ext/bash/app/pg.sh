#!/usr/bin/env bash
function provision-app-pg {
  section "PostgreSQL Client"
  install-packages libpq-dev
}
