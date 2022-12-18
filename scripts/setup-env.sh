#!/bin/bash

set -ueo pipefail

export ADMIN_USERNAME=${ADMIN_USERNAME:-admin}

export APP_DIR=${APP_DIR:-/opt/automated-workstation/app}
export VENV_DIR=${VENV_DIR:-/opt/automated-workstation/.venv}

export PYTHON_VERSION=${PYTHON_VERSION:-python3}
export PYTHON_PIP_VERSION=${PYTHON_PIP_VERSION:-pip3}
export ANSIBLE_COLLECTIONS_PATH="~/.ansible/collections"

. $APP_DIR/scripts/utils.sh

log ""
log "---------------------------"
log "Executing `basename \"$0\"`"
log ""

oldPwd=`pwd`

# Just delete any caching directory.
fact_caching_connection=`grep -E "^fact_caching_connection *=" $APP_DIR/ansible/ansible.cfg | sed 's/fact_caching_connection=//g'`
if [ -d $fact_caching_connection ]; then
	log "Removing $fact_caching_connection directory."
	sudo rm -rf $fact_caching_connection
fi

# Prerequisites
prerequisites() {
	$PYTHON_VERSION -m venv $VENV_DIR
	. $VENV_DIR/bin/activate

	$PYTHON_PIP_VERSION install --upgrade \
		pip \
		ansible

	ansible-galaxy collection install -vvv \
		--upgrade \
		--force-with-deps \
		--collections-path $ANSIBLE_COLLECTIONS_PATH \
		--requirements-file $APP_DIR/ansible/requirements.yml
}

log "In directory: `pwd`."
prerequisites

cd $oldPwd
