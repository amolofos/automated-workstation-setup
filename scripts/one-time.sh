#!/bin/bash

set -uxo pipefail

if ! command -v sudo >/dev/null 2>&1; then
	>&2 echo "This script requires 'sudo' binary to be installed"
	exit 1
fi

if [ "$(id -u)" -eq "0" ]; then
	>&2 echo "This script must be run as normal user"
	exit 1
fi

git clone https://github.com/amolofos/automated-workstation-setup.git amolofos-automated-workstation-setup

cd amolofos-automated-workstation-setup/ansible

sudo su root
ansible-playbook -i inventory/ 00-provision-one-time.yml
