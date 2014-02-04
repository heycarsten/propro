#!/usr/bin/env bash

function provision-app-pg {
  announce "Install PostgreSQL Client"
  install-packages libpq-dev
}
