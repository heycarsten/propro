#!/bin/bash
set -e
set -u
exec &> /root/full_provision.log

function pp-source {
  source ../propro/$1.sh
}

# Load libs
pp-source "propro"
pp-source "ubuntu"
pp-source "system"
pp-source "app"
pp-source "rvm"
pp-source "pg"
pp-source "pg-client"
pp-source "pg-server"
pp-source "db"
pp-source "redis"
pp-source "nginx"
pp-source "nginx-site"
pp-source "puma-service"
pp-source "sidekiq-service"
pp-source "extras"

# Configuration
APP_DOMAIN="" # required
APP_AUTHORIZED_GITHUB_USERS="" # required
DB_NAME="" # required
DB_USER="" # required
SYSTEM_HOSTNAME="" # required
SYSTEM_FQDN="" # required
SYSTEM_ADMIN_AUTHORIZED_GITHUB_USERS="" # required
SYSTEM_ADMIN_SUDO_PASSWORD="" # required
SIDEKIQ_CONFIG_FILE_NAME="sidekiq.yml" # probably change to {RACK_ENV}.yml
APP_PUMA_CONFIG_FILE_NAME="puma.rb" # probably change to {RACK_ENV}.rb
SYSTEM_PRIVATE_IP=""
SYSTEM_ALLOW_PRIVATE_IPS=""
RVM_RUBY_VERSION="2.0.0"
REDIS_VERSION="2.8.4"
REDIS_FORCE_64BIT="no" # Force 64bit build even if available memory is lte 4GiB
REDIS_BIND_IP=""
NGINX_VERSION="1.4.4"
NGINX_ACCESS_LOG_FILE_NAME="access.log"
NGINX_ERROR_LOG_FILE_NAME="error.log"
NGINX_DEPENDENCIES="libpcre3-dev libssl-dev"

function provision {
  provision-system
  provision-app
  provision-rvm
  provision-db
  provision-redis
  provision-nginx
  provision-nginx-site
  provision-puma-service
  provision-sidekiq-service
  provision-extras
  finished
  reboot-system
}

provision
