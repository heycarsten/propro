#!/usr/bin/env bash
#
# Provides tools and commands for deploying a Rack application with Capistrano
export APP_DOMAIN="" # @require
export APP_AUTHORIZED_GITHUB_USERS="" # @require
export APP_USER="deploy" # @specify
export APPS_DIR="/sites" # @specify
export APP_ENV="production" # @specify

function get-app-dir {
  echo "$APPS_DIR/$APP_DOMAIN"
}

function get-app-shared-dir {
  echo "$(get-app-dir)/shared"
}

function get-app-shared-tmp-dir {
  echo "$(get-app-shared-dir)/tmp"
}

function get-app-shared-log-dir {
  echo "$(get-app-shared-dir)/log"
}

function get-app-shared-sockets-dir {
  echo "$(get-app-shared-dir)/sockets"
}

function get-app-shared-config-dir {
  echo "$(get-app-shared-dir)/config"
}

function get-app-current-dir {
  echo "$(get-app-dir)/current"
}

function get-app-releases-dir {
  echo "$(get-app-dir)/releases"
}

function get-app-current-public-dir {
  echo "$(get-app-current-dir)/public"
}

function get-app-user {
  echo $APP_USER
}

function get-app-home {
  echo "/home/$(get-app-user)"
}

function get-app-env {
  echo $APP_ENV
}

function get-app-id {
  path-to-id $APP_DOMAIN
}

# $1 path
function app-mkdir {
  announce-item "$1"
  as-user-mkdir $APP_USER "$1"
}

function app-create-user {
  add-user $APP_USER "" ""
  add-pubkeys-from-github $APP_USER "$APP_AUTHORIZED_GITHUB_USERS"
}

function app-create-dirs {
  announce "Building app directory tree:"
  app-mkdir "$APPS_DIR"
  app-mkdir "$(get-app-dir)"
  app-mkdir "$(get-app-releases-dir)"
  app-mkdir "$(get-app-shared-config-dir)"
  app-mkdir "$(get-app-shared-dir)"
  app-mkdir "$(get-app-shared-tmp-dir)"
  app-mkdir "$(get-app-shared-log-dir)"
  app-mkdir "$(get-app-shared-sockets-dir)"
}

function provision-app {
  app-create-user
  app-create-dirs
}
