#!/usr/bin/env bash
function provision-app-node {
  section "Node.js"
  add-repository ppa:chris-lea/node.js
  update-sources
  install-packages nodejs
}
