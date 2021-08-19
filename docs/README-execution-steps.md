# Execution

## First run

* One time script
Install prerequisite software. We should have python3 installed and ansible. These are covered by the following script. It requires sudo priviledges.

  * Automated run
  ```bash
  curl https://raw.githubusercontent.com/amolofos/automated-workstation-setup/master/scripts/one-time-debian.sh | bash
  ```
  * Execute them locally
  ```bash
  git clone https://github.com/amolofos/automated-workstation-setup.git amolofos-automated-workstation-setup


  cd amolofos-automated-workstation-setup
  ./scripts/one-time-debian.sh
  ```

## Scheduled runs
* Execute the playbook manually
```bash
# Go to the locally checked out repository
cd amolofos-automated-workstation-setup

./scripts/scheduled-debian.sh
```

* Execute the playbook as a cron job
The ansible scripts already setup a cron job against admin user that will be executed at lunch (1pm) daily.
```bash
# As admin
$ crontab -l
#Ansible: Automated workstation setup
0 13 * * * /home/admin/scripts/admin-cronjob.sh
```
