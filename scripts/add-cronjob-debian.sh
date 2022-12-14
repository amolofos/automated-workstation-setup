#!/bin/bash
#
# It is expected to be run under admin user.
#
set -ueo pipefail

export ADMIN_USERNAME=${ADMIN_USERNAME:-admin}

export APP_DIR=${APP_DIR:-/opt/automated-workstation/app}
export VENV_DIR=${VENV_DIR:-/opt/automated-workstation/.venv}

. $APP_DIR/scripts/setup-env.sh

log ""
log "---------------------------"
log "Executing `basename \"$0\"`"
log ""

oldPwd=`pwd`

# Run ansible
run_ansible() {
	. $VENV_DIR/bin/activate
	cd $APP_DIR/ansible

	log "In directory: `pwd`."
	log "Executing: 	ansible-playbook -b -u $ADMIN_USERNAME amolofos.ansible_collection_workstation.p00_add_cronjob"
	ansible-playbook -b -u $ADMIN_USERNAME amolofos.ansible_collection_workstation.p00_add_cronjob

	cd $oldPwd
}

run_ansible
