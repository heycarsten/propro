#!/usr/bin/env bash
# requires app.sh
export RVM_CHANNEL="stable"
RVM_REQUIRED_PACKAGES="curl gawk g++ gcc make libc6-dev libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev"
RVM_DEFAULT_GEMS="bundler" #@specify

# $1 unix user
# $2 ruby version
function rvm-install-for-user {
  section "RVM"
  install-packages $RVM_REQUIRED_PACKAGES

  announce "Install RVM for user $1"
  su - $1 -c "curl -L https://get.rvm.io | bash -s $RVM_CHANNEL"
  su - $1 -c "rvm autolibs read-fail"

  announce "Install Ruby $2 for user $1"
  su - $1 -c "rvm install $2"

  announce "Set Ruby $2 as default for user $1"
  su - $1 -c "rvm --default use $2"

  announce "Install default gems"
  su - $1 -c "gem install $RVM_DEFAULT_GEMS"
}
