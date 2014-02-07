#!/usr/bin/env bash
function vagrant-system-install-user-aliases {
  announce "Installing helper aliases for user: $VAGRANT_USER"
  tee -a /home/$VAGRANT_USER/.profile <<EOT
alias be="bundle exec"
alias r="bin/rails"
alias v="cd $VAGRANT_DATA_DIR"
cd ~/$VAGRANT_DATA_DIR
EOT
}

function vagrant-system-purge-grub-menu-config {
  ucf --purge /boot/grub/menu.lst
}

function provision-vagrant-system {
  section "Vagrant System"
  vagrant-system-purge-grub-menu-config
  system-upgrade
  system-configure-timezone
  system-configure-locale
  system-install-packages
  system-configure-shared-memory
  system-install-sources
  vagrant-system-install-user-aliases
}
