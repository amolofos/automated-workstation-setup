#!/bin/bash

set -ueo pipefail

./scripts/one-time-debian.sh
sudo -u admin sh -c "./scripts/scheduled-debian.sh"
