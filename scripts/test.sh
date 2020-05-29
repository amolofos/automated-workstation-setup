#!/bin/bash

AUTOMATED_WORKSTATION_NAME=${AUTOMATED_WORKSTATION_NAME-workstation}
AUTOMATED_WORKSTATION_REPOSITORY=${AUTOMATED_WORKSTATION_REPOSITORY-https://github.com/amolofos/automated-workstation-setup.git}
AUTOMATED_WORKSTATION_LOCAL_DIR=${AUTOMATED_WORKSTATION_LOCAL_DIR-/tmp/automated_workstation}
AUTOMATED_WORKSTATION_SECRETS_DIR=${AUTOMATED_WORKSTATION_SECRETS_DIR-/opt/protected/ansible-vault}
AUTOMATED_WORKSTATION_SECRETS_FILE=${AUTOMATED_WORKSTATION_SECRETS_FILE-vault.yml}

ansible-playbook -vvvv 01-provision-all.yml \
	-e "external_protected_secrets_dir=$AUTOMATED_WORKSTATION_SECRETS_DIR" \
	-e "external_protected_secrets_env=$AUTOMATED_WORKSTATION_NAME" \
	-e "external_protected_secrets_file=$AUTOMATED_WORKSTATION_SECRETS_FILE" \
	-e "ansible_python_interpreter=/usr/bin/python"
