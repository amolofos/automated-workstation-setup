#!/bin/bash

set -ueo pipefail

sudo -u admin sh -c "./scripts/scheduled-debian.sh"
