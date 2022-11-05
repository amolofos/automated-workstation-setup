#!/bin/bash

set -ueo pipefail

./docker-entrypoint-one-time.sh
./docker-entrypoint-scheduled.sh
