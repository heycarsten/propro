#!/bin/bash

function provision-pg-client {
  announce "Install PostgreSQL Client"
  pg-add-sources
  install-packages libpq-dev
}
