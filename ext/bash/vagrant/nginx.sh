#!/usr/bin/env bash
function provision-vagrant-nginx {
  section "Nginx"
  nginx-install
  nginx-configure
  nginx-conf-add-gzip
  nginx-conf-add-mimetypes

  announce "Adding Nginx config for Vagrant"
  tee "$NGINX_SITES_DIR/vagrant.conf" <<EOT
upstream rack_app {
  server 127.0.0.1:3000 fail_timeout=0;
}

server {
  root $VAGRANT_DATA_DIR/public;

  access_log /dev/null;
  error_log /dev/null;

  try_files \$uri/index.html \$uri.html \$uri @upstream_app;

  location @upstream_app {
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;
    proxy_redirect off;
    proxy_pass http://rack_app;
  }
}
EOT
}
