#!/bin/bash
#
# It is expected to be run under admin user.
#
set -ueo pipefail

log() {
	echo "`date +"%Y-%m-%d %H:%M:%S"`: $1"
}

log ""
log "---------------------------"
log "Executing `basename \"$0\"`"
log ""

oldPwd=`pwd`

cd ansible/
# Just delete any caching directory.
fact_caching_connection=`grep -E "^fact_caching_connection *=" ./ansible.cfg | sed 's/fact_caching_connection=//g'`
if [ -d $fact_caching_connection ]; then
	log "Removing $fact_caching_connection directory."
	sudo rm -rf $fact_caching_connection
fi

# Run ansible
cmd=(ansible-playbook -b -u admin 00-add-cronjob.yml)
log "In directory: `pwd`."
log "Executing: ${cmd[*]}"
"${cmd[@]}"

cmd=(ansible-playbook -b -u admin 01-provision-all.yml)
log "In directory: `pwd`."
log "Executing: ${cmd[*]}"
"${cmd[@]}"

cd $oldPwd
