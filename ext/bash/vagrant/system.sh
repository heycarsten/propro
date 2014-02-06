#!/usr/bin/env bash
function vagrant-system-install-user-aliases {
  announce "Installing helper aliases for user: $VAGRANT_USER"
  tee -a /home/$VAGRANT_USER/.profile <<EOT
alias be="bundle exec"
alias r="bin/rails"
alias v="cd $VAGRANT_DATA_DIR"
v
EOT
}

function provision-vagrant-system {
  section "Vagrant System"
  system-upgrade
  system-configure-timezone
  system-configure-locale
  system-install-packages
  system-configure-shared-memory
  system-install-sources
  vagrant-system-install-user-aliases
}
