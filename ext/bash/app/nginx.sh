#!/usr/bin/env bash
function provision-app-nginx {
  section "Nginx"
  nginx-install
  nginx-configure
  nginx-conf-add-gzip
  nginx-conf-add-mimetypes
  nginx-create-logrotate
}
