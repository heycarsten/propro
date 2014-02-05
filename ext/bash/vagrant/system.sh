#!/usr/bin/env bash
function provision-vagrant-system {
  section "Vagrant System"
  system-upgrade
  system-configure-timezone
  system-configure-locale
  system-install-packages
  system-configure-shared-memory
  system-install-sources
}
