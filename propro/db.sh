#!/bin/bash

export DB_NAME="" # required
export DB_USER="" # required

function provision-db {
  provision-pg-server
  pg-server-create-user $DB_USER
  pg-server-create-db $DB_USER $DB_NAME
}
