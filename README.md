# Hyper Homelab
This is a home lab environment based on the following technologies:
- Microsoft Hyper-V
- Ansible
- Cloud-Init

## Secrets on the Host
### SSH Keys
Save the private keys in these two locations:
- TODO: reference the default location for WSL, and the default for PowerShell

Saving the encrypted private key in source control was considered as an option. However, having it in the `~/.ssh` directory makes ssh commands work more easily.

The public keys that reference these private keys are in `inventory/group_vars/all/vars.yml`.

## Ansible Vault PW
- Save a password file in `~/.ansible/vault_pw.txt`.
- This will decrypt the `vault.yml` files.

# Host Box Prep
The whole idea of Ansible is to codify the infrastructure, and avoid creating "snowflake" application servers. *In our efforts to do that, we need to avoid creating a "snowflake" virtualization/Ansible server!*

Our goal is is to make the host server configuratoin as simple as possible.

## WSL / Ubuntu
- Save the Ansible vault PW in this file: `~/.ansible/vault_pw.txt`.
  - This will be used to decrypt files using `ansible-vault`
  - **Be sure to save this PW safely outside of source control**
- Run `ssh-keygen` to create the public/private keypair in `~/.ssh/`

## Windows PowerShell
Enable to run script files.

Copy the private key file to a place where the `ssh` command in PowerShell will expect it.
```sh
# from WSL
cp ~/.ssh/id_rsa /mnt/c/Users/[username]/.ssh/
```
## Create SSH Keypairs

- Install Windows 10 Pro
- Install VS Code
- Install Ansible
-- But NOT on Windows
-- Requires WSL
- Install Python
-- Works much better from MS Store478965
- Enable Hyper-V
- Hyper-V Networking Workaround
- Run ansible on specific location (within /mnt/c)
- https://github.com/microsoft/WSL/issues/4288
- WSL Visual Studio Code Extension
- Do not install ansible via PIP (use package manager)
- Same for pip and literally everything.

# Resources
https://github.com/geerlingguy/ansible-for-devops

https://www.ansiblefordevops.com/
