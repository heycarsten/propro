#!/usr/bin/env bash

export SYSTEM_SHMALL_PERCENT="0.75" # @specify
export SYSTEM_SHMMAX_PERCENT="0.5" # @specify
export SYSTEM_BASE_PACKAGES="curl vim-nox less htop build-essential openssl"
export SYSTEM_TIMEZONE="Etc/UTC" # @specify
export SYSTEM_LOCALE="en_US.UTF-8" # @specify
export SYSTEM_SOURCES_PG_KEY_URL="http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc"

function system-configure-shared-memory {
  announce "Configuring shared memory"
  install-packages bc

  local shmall=$(get-kernel-shmall $SYSTEM_SHMALL_PERCENT)
  local shmmax=$(get-kernel-shmmax $SYSTEM_SHMMAX_PERCENT)

  sysctl -w kernel.shmall=$shmall
  sysctl -w kernel.shmmax=$shmmax
  tee -a /etc/sysctl.conf <<EOT

kernel.shmall = $shmall
kernel.shmmax = $shmmax
EOT
}

function system-install-packages {
  announce "Install base packages"
  install-packages $SYSTEM_BASE_PACKAGES
}

function system-configure-timezone {
  announce "Set timezone to $SYSTEM_TIMEZONE"
  set-timezone $SYSTEM_TIMEZONE
}

function system-configure-locale {
  announce "Set locale to $SYSTEM_LOCALE"
  set-locale $SYSTEM_LOCALE
}

function system-upgrade {
  announce "Update and upgrade system packages"
  upgrade-system
}

function system-add-pg-source {
  announce "Add PostgreSQL sources:"
  tee /etc/apt/sources.list.d/pgdg.list <<EOT
deb http://apt.postgresql.org/pub/repos/apt/ $(release-codename)-pgdg main
EOT

  announce-item "apt.postgresql.org"
  add-source-key $SYSTEM_SOURCES_PG_KEY_URL
  update-sources
}

function system-install-sources {
  system-add-pg-source
}
