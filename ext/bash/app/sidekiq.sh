#!/usr/bin/env bash
# requires app.sh
export APP_SIDEKIQ_CONFIG_DIR_RELATIVE="config/sidekiq"
export APP_SIDEKIQ_CONFIG_FILE_NAME="sidekiq.yml" # @specify
export APP_SIDEKIQ_PID_FILE_RELATIVE="tmp/sidekiq/worker.pid"
export APP_SIDEKIQ_CONF_FILE="/etc/sidekiq.conf"

APP_SIDEKIQ_CONFIG_FILE_RELATIVE="$APP_SIDEKIQ_CONFIG_DIR_RELATIVE/$APP_SIDEKIQ_CONFIG_FILE_NAME"

function provision-app-sidekiq {
  section "Sidekiq"
  announce "Create upstart for Sidekiq Manager"
  tee /etc/init/sidekiq-manager.conf <<EOT
description "Manages the set of sidekiq processes"
start on runlevel [2345]
stop on runlevel [06]
env APP_SIDEKIQ_CONF="$APP_SIDEKIQ_CONF_FILE"

pre-start script
  for i in \`cat \$APP_SIDEKIQ_CONF_FILE\`; do
    app=\`echo \$i | cut -d , -f 1\`
    logger -t "sidekiq-manager" "Starting \$app"
    start sidekiq app=\$app
  done
end script
EOT

  announce "Create upstart for Sidekiq Workers"
  tee /etc/init/sidekiq.conf <<EOT
description "Sidekiq Background Worker"
stop on (stopping sidekiq-manager or runlevel [06])
setuid $APP_USER
setgid $APP_USER
respawn
respawn limit 3 30
instance \${app}

script
exec /bin/bash <<EOTT
  export HOME="\$(eval echo ~\$(id -un))"
  source \$HOME/.rvm/scripts/rvm
  logger -t sidekiq "Starting worker: \$app"
  cd \$app
  exec bundle exec sidekiq -C $APP_SIDEKIQ_CONFIG_FILE_RELATIVE -P $APP_SIDEKIQ_PID_FILE_RELATIVE
EOTT
end script

pre-stop script
exec /bin/bash <<EOTT
  export HOME="\$(eval echo ~\$(id -un))"
  source \$HOME/.rvm/scripts/rvm
  logger -t sidekiq "Stopping worker: \$app"
  cd \$app
  exec bundle exec sidekiqctl stop $APP_SIDEKIQ_PID_FILE_RELATIVE
EOTT
end script
EOT

  tee /etc/sidekiq.conf <<EOT
$(get-app-current-dir)
EOT

  announce "Adding temp dir:"
  app-mkdir "$(get-app-shared-tmp-dir)/sidekiq"

  announce "Adding sudoers entries"
  add-sudoers-entries $APP_USER "sidekiq-manager" ""
  add-sudoers-entries $APP_USER "sidekiq" "app=$(get-app-current-dir)"
}
