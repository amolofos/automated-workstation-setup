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
AUTOMATED_WORKSTATION_NAME=${AUTOMATED_WORKSTATION_NAME-workstation}
AUTOMATED_WORKSTATION_SECRETS_DIR=${AUTOMATED_WORKSTATION_SECRETS_DIR-/opt/protected/ansible-vault}

if [ -z ${AUTOMATED_WORKSTATION_ANSIBLE_VAULT_REPO+x} ]; then
	echo "AUTOMATED_WORKSTATION_ANSIBLE_VAULT_REPO is not set, will not checkout any git repository."
else
	echo "Clearing /opt/protected/ansible-vault and checking out AUTOMATED_WORKSTATION_ANSIBLE_VAULT_REPO repository."
	sudo mkdir -p $AUTOMATED_WORKSTATION_SECRETS_DIR
	sudo rm -rf $AUTOMATED_WORKSTATION_SECRETS_DIR/*
	sudo git clone ${AUTOMATED_WORKSTATION_ANSIBLE_VAULT_REPO} $AUTOMATED_WORKSTATION_SECRETS_DIR/*

	echo "Importing gpg encryption keys"
	if [ -f "$AUTOMATED_WORKSTATION_SECRETS_DIR/common/gnupg/$AUTOMATED_WORKSTATION_NAME.gpg.pub.asc" ]; then
		sudo gpg --import $AUTOMATED_WORKSTATION_SECRETS_DIR/common/gnupg/$AUTOMATED_WORKSTATION_NAME.gpg.pub.asc
	fi

	if [ -f "$AUTOMATED_WORKSTATION_SECRETS_DIR/common/gnupg/workstation.gpg.asc" ]; then
		sudo gpg --import $AUTOMATED_WORKSTATION_SECRETS_DIR/common/gnupg/$AUTOMATED_WORKSTATION_NAME.gpg.asc
	fi
fi

echo "Finished successfully."
