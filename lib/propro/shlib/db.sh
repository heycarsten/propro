#!/usr/bin/env bash

export DB_NAME="" # required
export DB_USER="" # required

function provision-db {
  provision-db-pg
  db-pg-create-user $DB_USER
  db-pg-create-db $DB_USER $DB_NAME
}
