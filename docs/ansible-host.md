# Ansible Host
Everything that needs to be done to have development environment that runs the Ansible playbooks.

# Programs
## Ansible Development and Running
- Visual Studio Code
- Ansible
  - Version 2.9 does not have a recent enough version of the `proxmox_kvm` module.
  - Install using the PPA method according to [Ansible Docs](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html?msclkid=0cfdb7b5b48311ec8206fab5f0405a81#installing-ansible-on-ubuntu)
  - This installs version 5.x
  - To confirm whether the module is installed, use `ansible-galaxy collection list` and/or `ansible-galaxy collection install community.general`
- Virt-Viewer
- `pip` and Proxmoxer
## iDRAC
Java, and "Iced Tea"

# Secrets (TODO - document more)
Secrets like the `root` password are all encrypted using `ansible vault`.

The password for that needs to be saved in the user that's running Ansible's home directory.
```sh
echo 'SamplePassword' > ~/.ansible/vault_pw.txt
```

- ssh keys

# Personalization
This will make life much easier.
```sh
echo 'alias ans="ansible-playbook -i inventory/hosts.yml --vault-password-file ~/.ansible/vault_pw.txt"' >> ~/.bashrc
source ~/.bashrc
```

# Running
Change directories to `ansible` (within this project folder) before running. Ansible is particular about where files are located in relation to each other, and what the current directory is.

The only other parameter that's normally required is the playbook.

Using the alias, running a test (`ping.yml`) playbook looks like this:
```sh
~/src/hyper-homelab/ansible$ ans ping.yml
```