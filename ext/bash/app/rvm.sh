#!/usr/bin/env bash
# requires app.sh
export APP_RVM_RUBY_VERSION="2.1.1" # @specify

function provision-app-rvm {
  rvm-install-for-user $APP_USER $APP_RVM_RUBY_VERSION
}
