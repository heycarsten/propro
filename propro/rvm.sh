#!/bin/bash
# requires app.sh

export RVM_CHANNEL="stable"
export RVM_RUBY_VERSION="2.0.0"
RVM_REQUIRED_PACKAGES="curl gawk g++ gcc make libc6-dev libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev"

function app-rvm-init {
  announce "Install RVM dependencies"
  install-packages $RVM_REQUIRED_PACKAGES

  announce "Install RVM for user $APP_USER"
  su - $APP_USER -c "curl -L https://get.rvm.io | bash -s $RVM_CHANNEL"
  su - $APP_USER -c "rvm autolibs read-fail"
}

function app-rvm-install {
  announce "Install Ruby $RVM_RUBY_VERSION for user $APP_USER"
  su - $APP_USER -c "rvm install $RVM_RUBY_VERSION"
}

function app-rvm-use-default {
  announce "Set Ruby $RVM_RUBY_VERSION as default for user $APP_USER"
  su - $APP_USER -c "rvm --default use $RVM_RUBY_VERSION"
}

function provision-rvm {
  section "RVM"
  rvm-init
  rvm-install
  rvm-use-default
}
