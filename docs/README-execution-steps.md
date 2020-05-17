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
Make sure your user is allowed run sudo. This is needed if the current, existing
user is not a sudo one.

```
usermod -aG sudo <username>
```

* Install secrets
We need to have specific files storing secrets in the local machine. See [README-secrets.md](docs/README-secrets.md)
file for details and a poc on how these secrets can be setup. The following are expected
  * /opt/protected/ansible-vault/vault_pass.sh
  * /opt/protected/ansible-vault/<workstation>/vault.yml encrypted (or not, depends on you :) )

## First run

* One time scripts
Note that this will clone locally the git repository that stores the ansible vault.
In order to do that, the ANSIBLE_VAULT_REPO environment variable should be set to the expected git
repository.

  * Automated run
  ```bash
  # Replase the git repo below with yours.
  export ANSIBLE_VAULT_REPO=https://github.com/amolofos/automated-workstation-ansible-vault-template.git
  curl https://raw.githubusercontent.com/amolofos/automated-workstation-setup/master/scripts/one-time.sh | bash
  ```
  * Execute them locally
  ```bash
  # Replase the git repo below with yours.
  export ANSIBLE_VAULT_REPO=https://github.com/amolofos/automated-workstation-ansible-vault-template.git

  # Checkout the repository
  git clone https://github.com/amolofos/automated-workstation-setup.git amolofos-automated-workstation-setup

  # Install prerequisite software
  # We should have python3 installed and ansible. These are covered by the following
  # script. It requires sudo priviledges.
  cd amolofos-automated-workstation-setup
  ./scripts/one-time.sh
  ```

* Bootstrap scripts
This needs to run using a user with root passwordless access.
  * Automated run
  ```bash
  curl https://raw.githubusercontent.com/amolofos/automated-workstation-setup/master/scripts/bootstrap.sh | bash
  ```
  * Execute them locally
  ```bash
  sudo su - root
  # Checkout the repository
  git clone https://github.com/amolofos/automated-workstation-setup.git amolofos-automated-workstation-setup

  cd amolofos-automated-workstation-setup/ansible

  ./scripts/bootstrap.sh
  ```

## Subsequent runs
* Execute the playbook