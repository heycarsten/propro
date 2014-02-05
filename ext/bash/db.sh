#!/usr/bin/env bash

export DB_NAME="" # @require
export DB_USER="" # @require

function provision-db {
  provision-db-pg
  db-pg-create-user $DB_USER
  db-pg-create-db $DB_USER $DB_NAME
}
