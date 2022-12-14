# Overview

This is an effort to provide scripts to setup my workstation in an automated, reproducible way. The scripts are meant to be generic and parameterised based on the provided group_vars.

## Status
[![ubuntu-ci status](https://github.com/amolofos/automated-workstation-setup/workflows/ubuntu-ci/badge.svg)](https://github.com/amolofos/automated-workstation-setup/actions)

## Project architecture
This is not a fancy project. We are installing a cron job in a system user which will be executed periodically and apply the expected state in our system.

This is done briefly by
* preparing the system
This is done by one-time bash script setting up users and necessary software.
* initialising the admin user for one time only
* scheduled execution using crontab entries

## Features
* Debian systems
* System settings (e.g. locale, timezone etc)
* Software installation including external keys and repositores
  * apt, snap & pip
  * Unattended upgrades
* dot files based on jinja2 templates
* multiple users supported

## Supported platforms
* Ubuntu 20.04
Developed and tested against it.

## Scripts
Under `scripts` folder, we have some scripts to helps us with some tasks, such as installing
python, ansible etc.
* [one-time-debian.sh](scripts/one-time-debian.sh)
Installs the basic software (ansible, python etc) and creates the admin user.
* [scheduled-debian.sh](scripts/scheduled-debian.sh)
It just executes the [v](ansible/01-provision-all.yml) playbook which takes care of everything.

## Ansible
Under `ansible` folder we have the playbooks that will run periodically.

# Execution
Refer to [README-execution-steps.md](docs/README-execution-steps.md).

# Documentation
  * [README-build.md](docs/README-build.md)
  * [README-execution-steps.md](docs/README-execution-steps.md)
  * [README-influences.md](docs/README-influences.md)
  * [README-record-architecture-decisions.md](docs/README-record-architecture-decisions.md)
  * [README-TODO.md](docs/README-TODO.md)

# License
The license of this repository and the work that the committers have added into is MIT.
However, it should be noted that some parts have been based on other projects and on
work of other users. One should check the source of the scripts before making use of it.
