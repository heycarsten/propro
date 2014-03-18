#!/usr/bin/env bash
function app-monit-install {
  install-packages monit
}

function app-monit-logrotate {
  announce "Create logrotate for Monit"
  tee /etc/logrotate.d/monit <<EOT
/var/log/monit.log {
        rotate 4
        weekly
        minsize 1M
        missingok
        create 640 root adm
        notifempty
        compress
        delaycompress
        postrotate
                invoke-rc.d monit reload > /dev/null
        endscript
}
EOT
}

function app-monit-configure {
  mv /etc/monit/monitrc /etc/monit/monitrc.defaults
  touch /etc/monit/monitrc
  tee "/etc/monit/monitrc" << EOT
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

include /etc/monit/conf.d/*
EOT
}

function provision-app-monit {
  section "Monit"
  app-monit-install
  app-monit-configure
  app-monit-logrotate
}
