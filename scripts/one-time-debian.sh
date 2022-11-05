#!/bin/bash
#
# It is expected to be run by root or any other privileged user.
#
set -ueo pipefail

ADMIN_USERNAME=admin
ADMIN_GROUP=admin

DEBIAN_FRONTEND=noninteractive
REPOSITORY_BRANCH=${GIT_BRANCH:-main}
REPOSITORY=${REPOSITORY:-https://github.com/amolofos/automated-workstation-setup.git}

log() {
	echo "`date +"%Y-%m-%d %H:%M:%S"`: $1"
}

log ""
log "---------------------------"
log "Executing `basename \"$0\"`"
log ""

echo "This script will:"
echo " * install various packages (sudo, python, ansible)"
echo " * create an '$ADMIN_GROUP' group that has password less sudo."
echo " * create an '$ADMIN_USERNAME' user under the '$ADMIN_GROUP' group."
echo " * adds the '$ADMIN_USERNAME' user to the 'sudo' group group."
echo "   The goal is to use '$ADMIN_USERNAME' user to run all the scripts and playbooks."
echo ""

if [ "$(id -u)" -eq "0" ]; then
	log "Installing sudo"
	apt-get update -qq >/dev/null 2>&1 && apt-get install --yes sudo >/dev/null 2>&1 || true
fi

if ! command -v sudo >/dev/null 2>&1; then
	log "'sudo' could not be installed. This script requires 'sudo' binary to be installed."
	exit 1
fi

# Create admin group and set it as passwordless sudo.
log "Create $ADMIN_GROUP group."
sudo groupadd --system --force $ADMIN_GROUP

log "Set $ADMIN_GROUP group as passwordless sudo."
echo "# `date +"%Y-%m-%d %H:%M:%S"`"         >  /tmp/99-admin-passwordless.new
echo "# Give $ADMIN_GROUP group passwordless sudo." >> /tmp/99-admin-passwordless.new
echo "%$ADMIN_GROUP  ALL=(ALL) NOPASSWD:ALL"        >> /tmp/99-admin-passwordless.new
visudo --check --quiet --strict -f /tmp/99-admin-passwordless.new
sudo EDITOR="cp /tmp/99-admin-passwordless.new" visudo -f /etc/sudoers.d/99-admin-passwordless
rm -f /tmp/99-admin-passwordless.new

log "Create $ADMIN_USERNAME system user."
id -u $ADMIN_USERNAME >/dev/null 2>&1 || sudo useradd --system --create-home --gid $ADMIN_GROUP $ADMIN_USERNAME
sudo usermod -a -G '' admin

log "Installing software-properties-common"
sudo apt-get update -qq >/dev/null 2>&1 && \
	sudo apt-get install -qq --yes --no-install-recommends software-properties-common

log "Installing python 3.8 and ansible"
sudo add-apt-repository --yes ppa:deadsnakes/ppa
sudo apt-add-repository --yes ppa:ansible/ansible
sudo apt-get update -qq >/dev/null 2>&1 && \
	sudo apt-get install -qq --yes --no-install-recommends ansible git python3.8 python3-apt

log "Installing GPG"
sudo apt-get install -qq --yes --no-install-recommends gpg gpg-agent rng-tools

log "Installing a crontab to $ADMIN_USERNAME user."
log "This will:"
log " * use the local ./scripts/add-cronjob-debian.sh"
log " or"
log " * clone $REPOSITORY repository into /tmp and run ./scripts/add-cronjob-debian.sh"
log " add-cronjob-debian.sh will install a script as crontab"
log " under $ADMIN_USERNAME user which will run periodically"
log " the scheduled-debian.sh script."
log ""

oldPwd=`pwd`

log `pwd`
log `ls -la`
log `tree`

# Hack for github actions.
if [ -f "/home/runner/work/automated-workstation-setup/automated-workstation-setup/" ]; then
	sudo chown admin:admin /home/runner/work/automated-workstation-setup/automated-workstation-setup
fi

if [ -f "./scripts/add-cronjob-debian.sh" ]; then
	cmd=(sudo -iu admin sh -c "cd $oldPwd; ./scripts/add-cronjob-debian.sh")

	# Just delete any caching directory.
	fact_caching_connection=`grep -E "^fact_caching_connection *=" ./ansible/ansible.cfg | sed 's/fact_caching_connection=//g'`
	if [ -d $fact_caching_connection ]; then
		log "Removing $fact_caching_connection directory."
		sudo rm -rf $fact_caching_connection
	fi
	sudo chown admin:admin ansible/

else
	cmd=(sudo -iu admin sh -c "rm -rf /tmp/amolofos-automated-workstation-setup-tmp/ && \
		git clone --quiet --branch $REPOSITORY_BRANCH $REPOSITORY --depth 1 /tmp/amolofos-automated-workstation-setup-tmp/ && \
		cd /tmp/amolofos-automated-workstation-setup-tmp/ && \
		./scripts/add-cronjob-debian.sh && \
		cd /tmp \
		&& rm -rf /tmp/amolofos-automated-workstation-setup-tmp/ \
	")
fi

log "In directory: `pwd`."
log "Executing: ${cmd[*]}"
"${cmd[@]}"

log "Finished successfully."
