#!/usr/bin/env bash
export NODE_VERSION="0.10.25" # @specify

function get-node-pkg-name {
  echo "node-v$NODE_VERSION-linux-$(get-archtype)"
}

function get-node-url {
  echo "http://nodejs.org/dist/v$NODE_VERSION/$(get-node-pkg-name).tar.gz"
}

function node-install {
  local tmpdir=$(get-tmp-dir)
  cd "$tmpdir"

  announce "Download Node $NODE_VERSION"
  download $(get-node-url)

  announce "Extract Node $NODE_VERSION"
  extract "$(get-node-pkg-name).tar.gz"

  announce "Install Node"
  cd "./$(get-node-pkg-name)"
  cp -r -t /usr/local bin include share lib

  cd ~/
  rm -r "$tmpdir"
}
