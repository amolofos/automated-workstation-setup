#!/bin/bash

set -uxo pipefail

#if ! command -v sudo >/dev/null 2>&1; then
#	>&2 echo "This script requires 'sudo' binary to be installed"
#	exit 1
#fi
#
#if [ "$(id -u)" -eq "0" ]; then
#	>&2 echo "This script must be run as normal user"
#	exit 1
#fi

AUTOMATED_WORKSTATION_NAME=${AUTOMATED_WORKSTATION_NAME-workstation}
AUTOMATED_WORKSTATION_REPOSITORY=${AUTOMATED_WORKSTATION_REPOSITORY-https://github.com/amolofos/automated-workstation-setup.git}
AUTOMATED_WORKSTATION_LOCAL_DIR=${AUTOMATED_WORKSTATION_LOCAL_DIR-/tmp/automated_workstation}
AUTOMATED_WORKSTATION_SECRETS_DIR=${AUTOMATED_WORKSTATION_SECRETS_DIR-/opt/protected/ansible-vault}
AUTOMATED_WORKSTATION_SECRETS_FILE=${AUTOMATED_WORKSTATION_SECRETS_FILE-vault.yml}

#cd /tmp/
#rm -rf $AUTOMATED_WORKSTATION_LOCAL_DIR
#git clone $AUTOMATED_WORKSTATION_REPOSITORY $AUTOMATED_WORKSTATION_LOCAL_DIR
#
#cd $AUTOMATED_WORKSTATION_LOCAL_DIR/ansible

ansible-playbook -vvvv 00-provision-bootstrap.yml \
	-e "external_protected_secrets_dir=$AUTOMATED_WORKSTATION_SECRETS_DIR" \
	-e "external_protected_secrets_env=$AUTOMATED_WORKSTATION_NAME" \
	-e "external_protected_secrets_file=$AUTOMATED_WORKSTATION_SECRETS_FILE"
