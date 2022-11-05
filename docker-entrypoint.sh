#!/bin/bash

set -ueo pipefail

pwd || true

tree || true

./docker-entrypoint-one-time.sh
./docker-entrypoint-scheduled.sh
