#!/usr/bin/env bash
function vagrant-pg-create-user {
  announce "Create database user: $1"
  su - $PG_USER -c "createuser -s $VAGRANT_USER"
}

function provision-vagrant-pg {
  provision-pg
  vagrant-pg-create-user
}
