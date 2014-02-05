#!/usr/bin/env bash
function provision-app-nginx {
  provision-nginx
  nginx-create-logrotate
}
