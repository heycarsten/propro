#!/usr/bin/env bash
# requires nginx.sh
# requires app.sh
# requires app/puma.sh
export APP_PUMA_NGINX_ACCESS_LOG_FILE_NAME="access.log" # @specify
export APP_PUMA_NGINX_ERROR_LOG_FILE_NAME="error.log" # @specify
APP_PUMA_NGINX_ACCESS_LOG_FILE="$NGINX_LOG_DIR/$APP_PUMA_NGINX_ACCESS_LOG_FILE_NAME"
APP_PUMA_NGINX_ERROR_LOG_FILE="$NGINX_LOG_DIR/$APP_PUMA_NGINX_ERROR_LOG_FILE_NAME"

function provision-app-puma-nginx {
  tee "$NGINX_SITES_DIR/$APP_DOMAIN.conf" <<EOT
upstream $(get-app-id) {
  server unix:$(get-app-puma-socket-file) fail_timeout=0;
}

# Redirect www.$APP_DOMAIN => $APP_DOMAIN
server {
  listen 80;
  listen 443 ssl;
  server_name www.$APP_DOMAIN;
  return 301 \$scheme://$APP_DOMAIN\$request_uri;
}

server {
  server_name $APP_DOMAIN;
  root $(get-app-current-public-dir);

  access_log $APP_PUMA_NGINX_ACCESS_LOG_FILE main;
  error_log  $APP_PUMA_NGINX_ERROR_LOG_FILE notice;

  location ~* \.(eot|ttf|woff)\$ {
    add_header Access-Control-Allow-Origin *;
  }

  location ~ ^/(assets)/ {
    root $(get-app-current-public-dir);
    expires max;
    add_header Cache-Control public;
    gzip_static on;
  }

  try_files \$uri/index.html \$uri.html \$uri @rack_app;

  location @rack_app {
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;
    proxy_redirect off;
    proxy_pass http://$(get-app-id);
  }

  error_page 500 502 503 504 /500.html;

  location = /500.html {
    root $(get-app-current-public-dir);
  }
}
EOT
}
