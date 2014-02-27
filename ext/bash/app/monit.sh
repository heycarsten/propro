#!/usr/bin/env bash
function monit-install {
  install-packages monit
}

function provision-app-monit {
  section "Monit"
  monit-install
}
