#!/usr/bin/env bash
# requires app.sh

export APP_RVM_CHANNEL="stable"
export APP_RVM_RUBY_VERSION="2.0.0"
APP_RVM_REQUIRED_PACKAGES="curl gawk g++ gcc make libc6-dev libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev"

function app-rvm-init {
  announce "Install RVM dependencies"
  install-packages $APP_RVM_REQUIRED_PACKAGES

  announce "Install RVM for user $APP_USER"
  su - $APP_USER -c "curl -L https://get.rvm.io | bash -s $APP_RVM_CHANNEL"
  su - $APP_USER -c "rvm autolibs read-fail"
}

function app-rvm-install {
  announce "Install Ruby $APP_RVM_RUBY_VERSION for user $APP_USER"
  su - $APP_USER -c "rvm install $APP_RVM_RUBY_VERSION"
}

function app-rvm-use-default {
  announce "Set Ruby $APP_RVM_RUBY_VERSION as default for user $APP_USER"
  su - $APP_USER -c "rvm --default use $APP_RVM_RUBY_VERSION"
}

function provision-app-rvm {
  section "RVM"
  app-rvm-init
  app-rvm-install
  app-rvm-use-default
}
