#!/usr/bin/env bash
function monit-install {
  install-packages monit
}

function provision-app-monit {
  section "Monit"
  monit-install
  mv /etc/monit/monitrc /etc/monit/monitrc.defaults
  touch /etc/monit/monitrc
  tee "/etc/monit/monitrc/" << EOT
\# copy into /etc/monit/monitrc
\# set ownership to root:root
\# set permissions to 600
set daemon 60
set logfile syslog facility log_daemon
set mailserver localhost
\#set alert admin@domain.com

set httpd port 2812

allow localhost
allow admin:monit

include /etc/monit/conf.d/*
EOT
}
