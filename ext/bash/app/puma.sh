#!/usr/bin/env bash
export APP_PUMA_CONFIG_DIR_RELATIVE="config/puma"
export APP_PUMA_CONFIG_FILE_NAME="puma.rb" # @specify
export APP_PUMA_CONF_FILE="/etc/puma.conf"

APP_PUMA_CONFIG_FILE_RELATIVE="$APP_PUMA_CONFIG_DIR_RELATIVE/$APP_PUMA_CONFIG_FILE_NAME"

function get-app-puma-socket-file {
  echo "$(get-app-shared-sockets-dir)/puma.sock"
}

function provision-app-puma {
  section "Puma"
  announce "Create upstart for Puma"
  tee /etc/init/puma.conf <<EOT
description "Puma Background Worker"
stop on (stopping puma-manager or runlevel [06])
setuid $APP_USER
setgid $APP_USER
respawn
respawn limit 3 30
instance \${app}
script
exec /bin/bash <<'EOTT'
  export HOME="\$(eval echo ~\$(id -un))"
  source "\$HOME/.rvm/scripts/rvm"
  cd \$app
  logger -t puma "Starting server: \$app"
  exec bundle exec puma -C $APP_PUMA_CONFIG_FILE_RELATIVE
EOTT
end script
EOT

  announce "Create upstart for Puma Workers"
  tee /etc/init/puma-manager.conf <<EOT
description "Manages the set of Puma processes"
start on runlevel [2345]
stop on runlevel [06]
# /etc/puma.conf format:
# /path/to/app1
# /path/to/app2
env APP_PUMA_CONF="$APP_PUMA_CONF_FILE"
pre-start script
  for i in \`cat \$APP_PUMA_CONF\`; do
    app=\`echo \$i | cut -d , -f 1\`
    logger -t "puma-manager" "Starting \$app"
    start puma app=\$app
  done
end script
EOT

  tee /etc/puma.conf <<EOT
$(get-app-current-dir)
EOT

  announce "Adding temp dir"
  app-mkdir "$(get-app-shared-tmp-dir)/puma"

  announce "Adding sudoers entries"
  add-sudoers-entries $APP_USER "puma-manager" ""
  add-sudoers-entries $APP_USER "puma" "app=$(get-app-current-dir)"

  provision-app-puma-nginx
}
