#!/usr/bin/env bash
export PROPRO_LOG_FILE="/root/provision.log"
export PROPRO_LOG_USE_COLOR="yes"
export PROPRO_DISABLE_LOG="no"

function log {
  echo -e "$1"

  if is-yes $PROPRO_DISABLE_LOG; then
    return 0
  fi

  if [ $PROPRO_LOG_FILE ]; then
    touch $PROPRO_LOG_FILE
    echo -e "$1" >> $PROPRO_LOG_FILE
  fi
}

# $1 text
function section {
  local msg="#### $1"
  log ""
  if is-yes $PROPRO_LOG_USE_COLOR; then
    log "\e[32m\e[1m$msg\e[0m"
  else
    log "$msg"
  fi
}

# $1 text
function announce {
  if is-yes $PROPRO_LOG_USE_COLOR; then
    log "\e[34m\e[1m--->\e[0m $1"
  else
    log "---> $1"
  fi
}

# $1 text
function announce-item {
  if is-yes $PROPRO_LOG_USE_COLOR; then
    log "     - \e[36m$1\e[0m"
  else
    log "     - $1"
  fi
}

function finished {
  section "Fin."
}

function cd-tmp {
  local dirname=$(mktemp -d)
  cd $dirname
  return $dirname
}

# $1 "yes" or "no"
function is-yes {
  if [ $1 == "yes" ]; then
    return 0
  else
    return 1
  fi
}

# $1 "yes" or "no"
function is-no {
  if [ $1 == "no" ]; then
    return 0
  else
    return 1
  fi
}

# $1 comma separated list
#
# example:
# > $ csl-to-wsl "item1,item2,item3"
# > item1 item2 item3
function csl-to-wsl {
  echo "$1" | sed 's/,/ /g'
}

# $1 path or relative uri
#
# example:
# > $ path-to-id example.com/neat/stuff
# > example_com_neat_stuff
function path-to-id {
  echo "$1" | sed -r 's/[-\.:\/\]/_/g'
}
