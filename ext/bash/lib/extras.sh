#!/usr/bin/env bash
export EXTRA_PACKAGES="" # @specify

function provision-extras {
  if [ -z "$EXTRA_PACKAGES" ]; then
    return 0
  fi

  section "Extras"
  install-packages $EXTRA_PACKAGES
}
