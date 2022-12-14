#!/bin/bash
#
# It is expected to be run by root or any other privileged user.
#
# This script should not depend on any other ones. The user must be
# able to run it without the need to checkout the entiry codebase first.
#
set -ueo pipefail

export ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
export ADMIN_GROUP=${ADMIN_GROUP:-admin}

export BASE_DIR=${BASE_DIR:-/opt/automated-workstation}
export APP_DIR=${APP_DIR:-/opt/automated-workstation/app}

export REPOSITORY_BRANCH=${GIT_BRANCH:-main}
export REPOSITORY=${REPOSITORY:-https://github.com/amolofos/automated-workstation-setup.git}

export PYTHON_VERSION=${PYTHON_VERSION:-python3}
export PYTHON_PIP_VERSION=${PYTHON_PIP_VERSION:-pip3}
export ANSIBLE_COLLECTIONS_PATH="~/.ansible/collections"

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
	apt-get update -qq && apt-get install --yes sudo || true
fi

if ! command -v sudo >/dev/null 2>&1; then
	log "'sudo' could not be installed. This script requires 'sudo' binary to be installed."
	exit 1
fi

# Create admin group and set it as passwordless sudo.
log "Create $ADMIN_GROUP group."
sudo groupadd --system --force $ADMIN_GROUP

log "Set $ADMIN_GROUP group as passwordless sudo."
echo "# `date +"%Y-%m-%d %H:%M:%S"`"                 >  /tmp/99-admin-passwordless.new
echo "# Give $ADMIN_GROUP group passwordless sudo." >> /tmp/99-admin-passwordless.new
echo "%$ADMIN_GROUP  ALL=(ALL) NOPASSWD:ALL"        >> /tmp/99-admin-passwordless.new
visudo --check --quiet --strict -f /tmp/99-admin-passwordless.new
sudo EDITOR="cp /tmp/99-admin-passwordless.new" visudo -f /etc/sudoers.d/99-admin-passwordless
rm -f /tmp/99-admin-passwordless.new

log "Create $ADMIN_USERNAME system user."
id -u $ADMIN_USERNAME >/dev/null 2>&1 || sudo useradd --create-home -s /bin/bash --gid $ADMIN_GROUP $ADMIN_USERNAME
sudo usermod -a -G '' admin
sudo touch /home/$ADMIN_USERNAME/.sudo_as_admin_successful

log "Installing software-properties-common and gpg"
sudo apt-get update -qq
sudo apt-get install -qq --yes --no-install-recommends \
	software-properties-common \
	gpg \
	gpg-agent \
	rng-tools

log "Installing python and git"
sudo add-apt-repository --yes ppa:deadsnakes/ppa
sudo apt-add-repository --yes ppa:ansible/ansible
sudo apt-get update -qq
sudo apt-get install -qq --yes --no-install-recommends \
	git \
	python3-apt \
	${PYTHON_VERSION} \
	${PYTHON_VERSION}-venv

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
oldUser=`whoami`

sudo chown -R $ADMIN_USERNAME:$ADMIN_GROUP $BASE_DIR;

if [ -f "$APP_DIR/scripts/add-cronjob-debian.sh" ]; then
	cmd() {
		log "In directory: `pwd`."
		log "Executing: sudo -u $ADMIN_USERNAME sh -c '$APP_DIR/scripts/add-cronjob-debian.sh'"

		sudo -u $ADMIN_USERNAME sh -c "
			$APP_DIR/scripts/add-cronjob-debian.sh;
		"
	}

	cmd

else
	sudo mkdir -p $APP_DIR
	sudo chown -R $ADMIN_USERNAME:$ADMIN_GROUP $BASE_DIR

	cmd() {
		sudo -iu admin sh -c "
			rm -rf $APP_DIR &&
				git clone --quiet --branch $REPOSITORY_BRANCH $REPOSITORY --depth 1 $APP_DIR &&
				cd $APP_DIR &&
				$APP_DIR/scripts/add-cronjob-debian.sh &&
				cd $HOME &&
				rm -rf $APP_DIR
		"
	}

	log "In directory: `pwd`."
	log "Executing: $APP_DIR/scripts/add-cronjob-debian.sh"
	cmd
fi

log "Finished successfully."
