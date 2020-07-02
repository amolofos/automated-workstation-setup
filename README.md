# Overview

This is an effort to provide scripts to setup my workstation in an automated,
reproducible way.

## Supported platforms
* Ubuntu 18.04
Developed and tested against it.

# Project architecture
With this project we are going to install a cron job in a system user which will
execute periodically and apply the expected state in our system.

This is done briefly by
* preparing the system
This is done by one-time scripts, bash and ansible, setting up users, keys and vault secrets.
* initialising the admin user for one time only
* scheduled execution using crontab entries

## Scripts
Under `scripts` folder, we have some scripts to helps us with some tasks, such as installing
python, ansible etc.

## Ansible
Under `ansible` folder

## Secrets
The project expects the following files to be in place in the local machine.
See [README-secrets.md](docs/README-secrets.md) file for details and a poc on
how these secrets can be setup.

  * /opt/protected/ansible-vault/vault_pass.sh
  This is set in vault_password_file configuration and must return the vault password.
  * The ansible-vault encrypted files
  These files should contain specific variables based on the [vault.yml](template/vault.yml) template.
  These are located based on the following ansible variables.
  ```
  external_protected_secrets_dir: "/opt/protected/ansible-vault"
  external_protected_secrets_env: "workstation"
  external_protected_secrets_file: "vault.yml"
  external_protected_secrets_ext: "yml"
  ```

# Execution
Refer to [README-execution-steps.md](docs/README-execution-steps.md).

# Documentation

* Guides
  * [README-ansible-roles.md](docs/README-ansible-roles.md)
  * [README-execution-steps.md](docs/README-execution-steps.md)
  * [README-repository-integrations.md](docs/README-repository-integrations.md)
  * [README-secrets.md](docs/README-secrets.md)

* Record Architectural Decisions
  * [0001 Record architecture decisions](docs/architecture/decisions/0001-record-architecture-decisions.md)
  * [0002 Ansible - do not use local connections](docs/architecture/decisions/0002-ansible-do-not-use-local-connections.md)
  * [0003 Storing secrets](docs/architecture/decisions/0003-storing-secrets.md)

# TODO
  [] Design a cleaner way of using values defined by this repo and the values
  defined in the secret
  [] Software
    [] Go
    [] Rust
    [] TeX (https://github.com/wtanaka/ansible-role-latex/)
    [] Alternatives for neovim (https://github.com/neovim/neovim/wiki/Installing-Neovim)
    [] Docker
    [] Nomad
    [] Vault
    [] Consul
    [] Terraform
    [] Kubernetes
    [] AWS
    [] GCP
    [] Azure
    [] Openshift
  [] Dot files

# License
The license of this repository and the work that the committers have added into is MIT.
However, it should be noted that some parts have been based on other projects and on
work of other users. One should check the source of the scripts before making use of it.

# Related projects
The following articles were used as a starting point for this repository.
* https://opensource.com/article/18/3/manage-workstation-ansible
* https://opensource.com/article/18/3/manage-your-workstation-configuration-ansible-part-2
* https://opensource.com/article/18/5/manage-your-workstation-ansible-part-3

The following articles and projects influenced how this project evolved over time.
* https://gitlab.com/jsherman82/ansible_article
* https://gitlab.com/tle06/ansible-workstation-deployment
* https://github.com/codica2/ubuntu-laptop-script
* https://github.com/tazboyz16/Ubuntu-Server-Auto-Install
* https://github.com/fazlearefin/ubuntu-dev-machine-setup
* https://github.com/webknjaz/ansible-gentoo-laptop
* https://gitlab.com/craigfurman/ansible-home
* https://github.com/cytopia/ansible-debian
* https://github.com/lvancrayelynghe/ansible-ubuntu
* https://github.com/myllynen/misc
* https://github.com/dyindude/ansible-linux-laptop

## Side related projects
* https://github.com/victoriadrake/dotfiles/ (https://victoria.dev/blog/how-to-set-up-a-fresh-ubuntu-desktop-using-only-dotfiles-and-bash-scripts)
* https://github.com/tomnomnom/dotfiles
