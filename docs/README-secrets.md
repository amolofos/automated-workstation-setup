# Overview
Storing secrets is a problematic area.
Storing secrets in a platform for private retrieval and usage is hard.
Storing secrets in an encrypted form and decrypting them automatically is also broken.
Creting a public project that depends on personal secrets adds complexity.

In all the above cases, at least one of the below is open to theft and intruition.
* Do we store the sensitive data plain text locally but secure them with file permissions?
* Do we store the sensitive data plain text remotely but secure them by authenticating to the remote server?
* Do we store the sensitive data encrypted alongside this repository?
  * How can others use this project easily?
* Do we store the sensitive data encrypted in a private separate repository?
* Do we store the sensitive data encrypted in a private remote vault?
* Where does the encryption/decryption key is stored? Where do the remote vault's credentials live?
  * In a separate private repository?
  * Are they created locally with file permission protection? How does this scale?
  * Are they stored in a remote vault and fetched manually? How does this scale?
* How do we combine this project with a set of private credentials?

# Options

## Store the secrets in plain text
Once could store the secrets in plain text in local files, in this repository,
in another repository (public or private). This is out of question for the obvious
risks that it introduces.

## Store the secrets in a remote vault.
(SecretHub)[https://secrethub.io] was checked. Here are some quotes on what it does
> Securely provision passwords and keys to the applications that power your business, with just a few lines of code.

> How SecretHub helps you protect access to secrets across your entire stack in a single afternoon
> 
> Much like a traditional password manager does for humans who log into websites, SecretHub automatically injects passwords and keys whenever a machine needs to  'log into' another machine, allowing you to automate software delivery without leaking secrets throughout your pipeline.

See (Decouple Application Secrets from Your CI/CD Pipeline)[https://secrethub.io/blog/decouple-application-secrets-from-ci-cd-pipeline/], (Build Keyless Apps by Extending Native AWS Identity)[https://secrethub.io/blog/build-keyless-apps-by-extending-native-aws-identity/] and (
How to inject secrets into Ansible playbooks with SecretHub)[https://secrethub.io/blog/how-to-inject-secrets-into-ansible-playbooks/] articles in their website on how to it works.

A similar approach has been followed by tle06 in his (ansible workstation deployment)[https://gitlab.com/tle06/ansible-workstation-deployment] project using azure vault.

### Pros
* Use an actual vault as-a-service to store our credentials and keys
* Solves the issue with private credentials stored in a public project

### Cons
* Some vaults are not free
* Possibly limited number of secrets in the free version of the vault
* Additional secrets to protect - vault username and password or token
* Does not solve the problem with the master password
* No versioning
* Limited auditing based on the capabilites of the remote vault

## Store the secrets in a remote platform.
In order to store our secrets we do not need a vault as a service. Once can
utilise any remote platforrm to store them. Once example can be a separate
private git repository that will hold the credentials in an encrypted form.

### Pros
* Use existing infrastructure, e.g. github
* Versioning
* Auditing based on git log

### Cons
* Remote git repository is not a proper vault service
* Additional secrets to protect and install- remote git username and password,
token or key
* Does not solve the problem with the master password
* Adds complexity on how we can combine files from two different repositories in
a single local folder

# Decision

## Secret location
Keeping this simple and loosly coupled, we expect the secrets to be available as
ansible yml variable files in specific location in the local machine. See the 
following variables in `group_vars/all.yml`.
```
external_protected_secrets_dir: "/opt/protected/ansible-vault"
external_protected_secrets_env: "workstation"
external_protected_secrets_file: "vault.yml"
external_protected_secrets_ext: "yml"
```

By default, the files are expected to be installed in `/opt/protected/ansible-vault/`
directory. The installation  scripts are going to source the
`/opt/protected/ansible-vault/{{ environment }}/vault.yml` file. See `templates/vault.yml`
for the expected content of the file.

## Vault master password
To keep things loosly coupled, a script located in `/opt/protected/ansible-vault/vault_pass.sh`
is expected to provide the vault password. The script is stated in vault_password_file
configuration item inside ansible.cfg.

# POC implementation
This is the approach that we are taking as part of this project. End users
can users may follow another implementation as far as the expected ansible
file is located in the dedicated location, e.g. `/opt/protected/ansible-vault/{{ environment }}/vault.yml`.

The location of the secrets will be provided in the designated directory but
they will originate from a git private repository. The remote private git
repository has been chosen since we favor simple auditing and version control
and we want to avoid the restrictions of the free vault as a service solutions
that exist out there.

The vault master password will be encrypted using GPG tool chain. The end user
is responsible for maintaining the private and public key of the local machine.

## Create GPG key
Pang Yan Han's (How to use GPG to encrypt stuff)[https://yanhan.github.io/posts/2017-09-27-how-to-use-gpg-to-encrypt-stuff.html] page explains the various steps in gpg key creation process.

* Install software
```
sudo apt-get install -y gpg gpg-agent
```
* Generate key
```
gpg --full-generate-key
```
* List your keys
```
gpg --list-keys
```
* Upload the public key to a public server
This is necessary only if one wants to encrypt files and send them to other people.
```
$ gpg --send-keys 4CD8E539CC39A8292A0A54DCDC957630A5AA9630
gpg: sending key DC957630A5AA9630 to hkps://hkps.pool.sks-keyservers.net
```
One can download that key by using the following command. 
```
gpg --keyserver keys.gnupg.net --search-key your.friend@yourfriendsdomain.com
```

## Create ansible password
The following is based on (xoyabc's gist)[https://gist.github.com/xoyabc/4ab27d181808affa6450ee481e0ff9b2].

* Create large random password for ansible-vault
```
mkdir -p /opt/protected/
openssl rand -base64 2048 | gpg -e -o /opt/protected/ansible-vault/ansible-vault-passphrase.gpg
```

* Or encrypt an already existing one
```
mkdir -p /opt/protected/
echo "$ANSIBLE_VAULT_PASSWORD" | gpg -e -o /opt/protected/ansible-vault/ansible-vault-passphrase.gpg
```

## Encrypt ansible vault
* Create the non-encrypted file based on (vault)[templates/vault.yml] template.
This file should be available in the location specified by external_protected_secrets_dir,
external_protected_secrets_env and external_protected_secrets_file ansible variables.
```
mkdir -p /opt/protected/ansible-vault/<workstation>/
/opt/protected/ansible-vault/<workstation>/vault.yml
```

* Encrypt the file.
```
ansible-vault encrypt --vault-password-file=/opt/protected/ansible-vault/vault_pass.sh /opt/protected/ansible-vault/<workstation>/vault.yml
```

## Store the encrypted files
We are going to store the encrypted files in a private git repository so that
we can update them and retrieve them easily. Once example of such git repository
can be found in (automated-workstation-ansible-vault-template)[https://github.com/amolofos/automated-workstation-ansible-vault-template].

# Bibliography
* [Presentation] (Turtles all the way down - Storing secrets in the Cloud and in the Data Center)[http://schd.ws/hosted_files/appsecusa2015/a5/Turtles.pdf]
* [Article] (Safely storing Ansible playbook secrets)[https://www.onwebsecurity.com/configuration/safely-storing-ansible-playbook-secrets.html]
* [stackexchange] (How do I run Ansible Azure playbooks while avoiding storing credentials in files?)[https://devops.stackexchange.com/questions/3806/how-do-i-run-ansible-azure-playbooks-while-avoiding-storing-credentials-in-files]
* Ansible and PGP
  * [Article] (Secrets with Ansible: Ansible Vault and GPG)[https://benincosa.com/?p=3235]
  * [Article] (Ansible Vault and GPG usage)[https://dirjax.github.io/20180103_ansible_gpg_vault.html] & (The Ansible POC)[https://github.com/brianmor/ansible-poc]
  * [Article] (Encrypting the Ansible Vault passphrase using GPG)[https://disjoint.ca/til/2016/12/14/encrypting-the-ansible-vault-passphrase-using-gpg/]
* [stackexchange]: (Where to put ansible-vault password)[https://devops.stackexchange.com/questions/3282/where-to-put-ansible-vault-password]
* (SecretHub)[https://secrethub.io/docs/start/getting-started/]

# Notes
* https://gist.github.com/tristanfisher/e5a306144a637dc739e7
* https://gist.github.com/xoyabc/4ab27d181808affa6450ee481e0ff9b2
