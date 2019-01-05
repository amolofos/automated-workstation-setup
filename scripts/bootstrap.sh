#!/bin/bash

set -uxo pipefail

if [ "$(id -u)" -eq "0" ]; then
	apt-get install -y sudo
fi

if ! command -v sudo >/dev/null 2>&1; then
	>&2 echo "This script requires 'sudo' binary to be installed"
	exit 1
fi

sudo apt-get install -y software-properties-common

sudo add-apt-repository --yes --update ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y python3.6
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
sudo update-alternatives --set python /usr/bin/python3.6

sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible

# PGP
sudo apt-get install -y gpg gpg-agent rng-tools

# Local ansible vault
PROTECTED_LOCAL_DIR=${PROTECTED_LOCAL_DIR-/opt/openbet/protected}
ANSIBLE_VAULT_LOCAL_DIR=${ANSIBLE_VAULT_LOCAL-/opt/openbet/protected/ansible-vault}
if [ -z ${ANSIBLE_VAULT_REPO+x} ]; then
	echo "ANSIBLE_VAULT_REPO is not set, will not checkout any git repository."
else
	echo "Clearing /opt/openbet/protected/ansible-vault and checking out ANSIBLE_VAULT_REPO repository."
	mkdir -p $PROTECTED_LOCAL_DIR
	rm -rf $ANSIBLE_VAULT_LOCAL_DIR/*
	git clone ${ANSIBLE_VAULT_REPO} $ANSIBLE_VAULT_LOCAL_DIR/*
fi

echo "Finished successfully."