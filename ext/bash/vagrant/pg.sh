#!/usr/bin/env bash
function vagrant-pg-create-user {
  announce "Create database user: $VAGRANT_USER"
  su - $PG_USER -c "createuser -s $VAGRANT_USER"
}

function provision-vagrant-pg {
  section "PostgreSQL Server"
  pg-install-packages
  pg-tune
  vagrant-pg-create-user
}
