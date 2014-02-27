#!/usr/bin/env bash
export APP_UNICORN_CONFIG_DIR_RELATIVE="config/"
export APP_UNICORN_CONFIG_FILE_NAME="unicorn.rb" # @specify

APP_UNICORN_CONFIG_FILE_RELATIVE="$APP_UNICORN_CONFIG_DIR_RELATIVE/$APP_UNICORN_CONFIG_FILE_NAME"

function get-app-unicorn-app-root {
  echo "$(get-app-current-dir)"
}

function get-app-unicorn-pid-file {
  echo "$(get-app-unicorn-app-root)/log/unicorn.pid"
}

function provision-app-unicorn {
  section "Unicorn"
  announce "Create init.d for Unicorn"

  tee /etc/init.d/unicorn <<EOT
#!/bin/sh
set -u
set -e

# copy this to /etc/init.d/unicorn
# set owner to root:root
# chmod a+x
# update-rc.d unicorn defaults
# adapted from http://gist.github.com/308216
APP_ROOT=$(get-app-unicorn-app-root)
PID=$(get-app-unicorn-pid-file)
OLD_PID="\$PID.oldbin"
ENV=$(get-app-env)
HOME=$(get-app-home)

cd \$APP_ROOT || exit 1

start_unicorn () {
        su deploy -c "cd \${APP_ROOT} && bin/unicorn -E \${ENV} -D -o 127.0.0.1 -c \${APP_ROOT}/config/unicorn.rb \${APP_ROOT}/config.ru"
}

sig () {
        test -s "\$PID" && kill -\$1 \`cat \$PID\`
}

oldsig () {
        test -s \$OLD_PID && kill -\$1 \`cat \$OLD_PID\`
}


case \$1 in
start)
        sig 0 && echo >&2 "Already running" && exit 0
        start_unicorn
        ;;
stop)
        sig QUIT && exit 0
        echo >&2 "Not running"
        ;;
force-stop)
        sig TERM && exit 0
        echo >&2 "Not running"
        ;;
restart|reload)
        sig HUP && echo reloaded OK && exit 0
        echo >&2 "Couldn't reload, starting unicorn instead"
        start_unicorn
        ;;
upgrade)
        sig USR2 && exit 0
        echo >&2 "Couldn't upgrade, starting unicorn instead"
        start_unicorn
        ;;
rotate)
        sig USR1 && echo rotated logs OK && exit 0
        echo >&2 "Couldn't rotate logs" && exit 1
        ;;
*)
        echo >&2 "Usage: \$0 <start|stop|restart|upgrade|rotate|force-stop>"
        exit 1
        ;;
esac

EOT

chmod +x /etc/init.d/unicorn

announce "Adding sudoers entries"
for event in start status stop reload restart; do
  tee -a /etc/sudoers.d/unicorn.entries <<EOT
$APP_USER ALL=NOPASSWD: /etc/init.d/unicorn $event
EOT
done

}

