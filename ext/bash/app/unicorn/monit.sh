#!/usr/bin/env bash
# requires nginx.sh
# requires app.sh
# requires app/unicorn.sh
export APP_UNICORN_NGINX_ACCESS_LOG_FILE_NAME="access.log" # @specify
export APP_UNICORN_NGINX_ERROR_LOG_FILE_NAME="error.log" # @specify
export APP_UNICORN_UPSTREAM_PORT=4000 #@specify
APP_UNICORN_NGINX_ACCESS_LOG_FILE="$NGINX_LOG_DIR/$APP_UNICORN_NGINX_ACCESS_LOG_FILE_NAME"
APP_UNICORN_NGINX_ERROR_LOG_FILE="$NGINX_LOG_DIR/$APP_UNICORN_NGINX_ERROR_LOG_FILE_NAME"

function provision-app-unicorn-monit {
  tee "/etc/monit/conf.d/$APP_DOMAIN.conf" <<EOT
# copy into /etc/monit/monitrc
# set ownership to root:root
# set permissions to 600
set daemon 60
set logfile syslog facility log_daemon
set mailserver localhost
#set alert admin@domain.com

set httpd port 2812

allow localhost
allow admin:monit

check process unicorn_app
  with pidfile $(get-app-unicorn-pid-file)
  group unicorn
  start program = "/etc/init.d/unicorn start" with timeout 100 seconds
  stop program = "/etc/init.d/unicorn stop"
EOT
}

