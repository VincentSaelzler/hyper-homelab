# Ansible Host
Everything that needs to be done to have development environment that runs the Ansible playbooks that administer the physical hosts.

A VM referred to as the "Dev Env" will be configured by the Ansbile Host to set up parts of the infrastructure that are virtualized and inside of a DMZ network.

## Manual Setup Steps
### OS Installation
This project assumes that the Ansible host will be running Ubuntu (or Ubuntu on Windows via WSL). Other distributions could probably be used with relatively minor changes.

**Windows:** Install Windows Subsystem for Linux
```ps
wsl --install
```
Download and install [virt-viewer](https://virt-manager.org/download/)

**Linux:** Install Ubuntu on physical hardware

### Bootstrap with Ansible and Git
Install apt software
```sh
sudo apt update && sudo apt full-upgrade && sudo apt autoremove && sudo reboot
sudo apt install git python3-pip
```
Install python software
```sh
python3 -m pip install --user ansible
export PATH=$PATH:$HOME/.local/bin #this is where python saves the executables
```
Clone repository
```sh
git clone https://github.com/VincentSaelzler/hyper-homelab.git ~/src/hyper-homelab
```
Run playbook to bootstrap host
```sh
ansible-playbook ~/src/hyper-homelab/ansible/ansible-host.yml --ask-become-pass --ask-vault-pass
```
Apply aliases
```sh
source ~/.bashrc
```


# Secrets
There is one critical secret that protects everything: **the Ansible vault password.**

The `ansible-host` playbook handles all of the other secrets, so no need to manually copy files, set PWs, or do other configuration.

Other secrets are encrypted and saved either as standalone files within `ansible/files/vault` or as variables within the `ansible/inventory/group_vars/all/vault.yml` file. Encrypted secrets include:
- passwords
- private ssh keys
- crypto private keys
- the vault PW itself

*The encrypted variables are referenced at the bottom of the `ansible/inventory/group_vars/all/vars.yml` file, so it's clear what the contents of the vault file are.*

# Running
Change directories to `ansible` (within this project folder) before running. Ansible is particular about where files are located in relation to each other, and what the current directory is.

The only other parameter that's normally required is the playbook.

Using the alias, running a test (`ping.yml`) playbook looks like this:
```sh
~/src/hyper-homelab/ansible$ ans ping.yml
```
