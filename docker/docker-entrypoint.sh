#!/bin/bash

set -ueo pipefail

export DEBIAN_FRONTEND=noninteractive

export ADMIN_USERNAME=${ADMIN_USERNAME:-admin}

$RUNTIME_DIR/scripts/one-time-debian.sh
if [ "$?" -gt 0 ]; then
  echo "one-time-debian.sh failed"
fi

sudo -u $ADMIN_USERNAME sh -c "$RUNTIME_DIR/scripts/scheduled-debian.sh"
