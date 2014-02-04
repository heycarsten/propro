#!/usr/bin/env bash

export NGINX_VERSION="1.4.4"
export NGINX_USER="nginx"
export NGINX_CONFIGURE_OPTS="--with-http_ssl_module --with-http_gzip_static_module"
export NGINX_CONF_FILE="/etc/nginx.conf"
export NGINX_ETC_DIR="/etc/nginx"
export NGINX_LOG_DIR="/var/log/nginx"
export NGINX_ACCESS_LOG_FILE_NAME="access.log"
export NGINX_ERROR_LOG_FILE_NAME="error.log"
export NGINX_DEPENDENCIES="libpcre3-dev libssl-dev"
export NGINX_WORKER_COUNT=$(get-processor-count)
export NGINX_PID_FILE="/var/run/nginx.pid"
export NGINX_CLIENT_MAX_BODY_SIZE="5m"
export NGINX_WORKER_CONNECTIONS="2000"

NGINX_SITES_DIR="$NGINX_ETC_DIR/sites"
NGINX_CONF_DIR="$NGINX_ETC_DIR/conf"

function nginx-install {
  local tmpdir=$(cd-tmp)

  announce "Install dependencies"
  install-packages $NGINX_DEPENDENCIES

  announce "Download $NGINX_VERSION"
  download http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz

  announce "Extract"
  extract nginx-$NGINX_VERSION.tar.gz

  announce "Configure"
  cd nginx-$NGINX_VERSION
  ./configure $NGINX_CONFIGURE

  announce "Compile"
  make

  announce "Install $NGINX_VERSION"
  make install

  cd ~/
  rm -rf $tmpdir
}

function nginx-configure {
  announce "Creating Nginx user"
  useradd -r $NGINX_USER

  announce "Adding Nginx directories"
  as-user-mkdir $NGINX_USER $NGINX_LOG_DIR
  mkdir -p $NGINX_ETC_DIR
  mkdir -p $NGINX_SITES_DIR
  mkdir -p $NGINX_CONF_DIR

  announce "Creating base Nginx config: $NGINX_CONF_FILE"
  tee $NGINX_CONF_FILE <<EOT
user $NGINX_USER;
pid $NGINX_PID_FILE;
ssl_engine dynamic;
worker_processes $NGINX_WORKER_COUNT;

events {
  multi_accept on;
  worker_connections $NGINX_WORKER_CONNECTIONS;
  use epoll;
}

http {
  sendfile on;

  tcp_nopush on;
  tcp_nodelay off;

  client_max_body_size $NGINX_CLIENT_MAX_BODY_SIZE;
  client_body_temp_path /var/spool/nginx-client-body 1 2;

  include /usr/local/nginx/conf/mime.types;
  default_type application/octet-stream;

  include /etc/nginx/conf/*.conf
  include /etc/nginx/sites/*.conf
}
EOT

  announce "Create logrotate for Nginx"
  tee /etc/logrotate.d/nginx <<EOT
$NGINX_LOG_DIR/*.log {
  daily
  missingok
  rotate 90
  compress
  delaycompress
  notifempty
  dateext
  create 640 nginx adm
  sharedscripts
  postrotate
    [ -f $NGINX_PID_FILE ] && kill -USR1 `cat $NGINX_PID_FILE`
  endscript
}
EOT

  announce "Writing Nginx upstart /etc/init/nginx.conf"
  tee /etc/init/nginx.conf <<EOT
description "Nginx HTTP Daemon"
author "George Shammas <georgyo@gmail.com>"

start on (filesystem and net-device-up IFACE=lo)
stop on runlevel [!2345]
env DAEMON="/usr/local/nginx/sbin/nginx -c $NGINX_CONF_FILE"
env PID="$NGINX_PID_FILE"
expect fork
respawn
respawn limit 10 5

pre-start script
  \$DAEMON -t
  if [ \$? -ne 0 ]
    then exit \$?
  fi
end script

exec \$DAEMON
EOT
}

function nginx-conf-add-mimetypes {
  announce "Adding mimetypes config"
  tee "$NGINX_CONF_DIR/mimetypes.conf" <<EOT
types_hash_max_size                     2048;

types {
  application/atom+xml                  atom;
  application/java-archive              jar war ear;
  application/javascript                js;
  application/json                      json;
  application/msword                    doc;
  application/pdf                       pdf;
  application/postscript                ps eps ai;
  application/rtf                       rtf;
  application/vnd.ms-excel              xls;
  application/vnd.ms-fontobject         eot;
  application/vnd.ms-powerpoint         ppt;
  application/vnd.wap.wmlc              wmlc;
  application/x-7z-compressed           7z;
  application/x-bittorrent              torrent;
  application/x-cocoa                   cco;
  application/x-font-ttf                ttf ttc;
  application/x-httpd-php-source        phps;
  application/x-java-archive-diff       jardiff;
  application/x-java-jnlp-file          jnlp;
  application/x-makeself                run;
  application/x-perl                    pl pm;
  application/x-pilot                   prc pdb;
  application/x-rar-compressed          rar;
  application/x-redhat-package-manager  rpm;
  application/x-sea                     sea;
  application/x-shockwave-flash         swf;
  application/x-stuffit                 sit;
  application/x-tcl                     tcl tk;
  application/x-x509-ca-cert            der pem crt;
  application/x-xpinstall               xpi;
  application/xhtml+xml                 xhtml;
  application/xml                       xml;
  application/zip                       zip;
  audio/midi                            mid midi kar;
  audio/mpeg                            mp3;
  audio/ogg                             oga ogg;
  audio/x-m4a                           m4a;
  audio/x-realaudio                     ra;
  audio/x-wav                           wav;
  font/opentype                         otf;
  font/woff                             woff;
  image/gif                             gif;
  image/jpeg                            jpeg jpg;
  image/png                             png;
  image/svg+xml                         svg svgz;
  image/tiff                            tif tiff;
  image/vnd.wap.wbmp                    wbmp;
  image/webp                            webp;
  image/x-icon                          ico;
  image/x-ms-bmp                        bmp;
  text/cache-manifest                   manifest appcache;
  text/css                              css;
  text/html                             html htm shtml;
  text/mathml                           mml;
  text/plain                            txt md;
  text/vnd.sun.j2me.app-descriptor      jad;
  text/vnd.wap.wml                      wml;
  text/x-component                      htc;
  text/xml                              rss;
  video/3gpp                            3gpp 3gp;
  video/mp4                             m4v mp4;
  video/mpeg                            mpeg mpg;
  video/ogg                             ogv;
  video/quicktime                       mov;
  video/webm                            webm;
  video/x-flv                           flv;
  video/x-mng                           mng;
  video/x-ms-asf                        asx asf;
  video/x-ms-wmv                        wmv;
  video/x-msvideo                       avi;
}
EOT
}

function nginx-conf-add-gzip {
  announce "Adding gzip config"
  tee $NGINX_CONF_DIR/gzip.conf <<EOT
gzip on;
gzip_buffers 32 4k;
gzip_comp_level 2;
gzip_disable "msie6";
gzip_http_version 1.1;
gzip_min_length 1100;
gzip_proxied any;
gzip_static on;
gzip_vary on;
gzip_types
  text/css
  text/plain
  application/javascript
  application/json
  application/rss+xml
  application/xml
  application/vnd.ms-fontobject
  font/truetype
  font/opentype
  image/x-icon
  image/svg+xml;
EOT
}

function provision-nginx {
  section "Nginx"
  nginx-install
  nginx-configure
  nginx-conf-add-gzip
  nginx-conf-add-mimetypes
}
