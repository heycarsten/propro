#!/usr/bin/env bash
export VAGRANT_RVM_RUBY_VERSION="2.1.2" # @specify

function provision-vagrant-rvm {
  rvm-install-for-user $VAGRANT_USER $VAGRANT_RVM_RUBY_VERSION
}
