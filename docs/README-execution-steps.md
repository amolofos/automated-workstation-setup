# Execution

## Prerequisites

Automating existing personal laptops is hard due to unavoidable snowflakes.
These prerequisites and one time scripts must be run to ensure the system is
in the expected state.

* Install fundamental tools
```
apt-get update
apt-get install --no-install-recommends --no-install-suggests -y \
  sudo
```

* Sudo permissions
Make sure your user is allowed run sudo
```
usermod -aG sudo <username>
```

* Install secrets
We need to have specific files storing secrets in the local machine. See [README-secrets.md](docs/README-secrets.md)
file for details and a poc on how these secrets can be setup. The following are expected
  * /opt/protected/ansible-vault/vault_pass.sh
  * /opt/protected/ansible-vault/<workstation>/vault.yml encrypted

## First run

* Define private repo of encrypted secrets
This is needed if the ansible encrypted secrets are stored in a remote repository and
one wants to checkout it automatically under /opt/protected/ansible-vault.
```
export ANSIBLE_VAULT_REPO=git@github.com:username/repository.git
```

* Bootstrap
  * Automated run
  ```bash
  curl https://raw.githubusercontent.com/amolofos/automated-workstation-setup/master/scripts/bootstrap.sh | bash
  ```
  * Execute them locally
  ```bash
  # Checkout the repository
  git clone https://github.com/amolofos/automated-workstation-setup.git amolofos-automated-workstation-setup

  # Install prerequisite software
  # We should have python3 installed and ansible. These are covered by the following
  # script. It requires sudo priviledges.
  cd amolofos-automated-workstation-setup
  sudo ./scripts/bootstrap.sh
  ```

* One time scripts
  * Automated run
  ```bash
  curl https://raw.githubusercontent.com/amolofos/automated-workstation-setup/master/scripts/one-time.sh | bash
  ```
  * Execute them locally
  ```bash
  # Checkout the repository
  git clone https://github.com/amolofos/automated-workstation-setup.git amolofos-automated-workstation-setup

  cd amolofos-automated-workstation-setup/ansible

  # Execute the one time playbook as root. It installs the users and defines their
  # passwordless login and must be executed as root.
  sudo su root
  ansible-playbook -i inventory/ 00-provision-one-time.yml
  ```

## Subsequent runs
* Execute the playbook