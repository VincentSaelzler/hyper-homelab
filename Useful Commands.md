# General Ansible Stuff
Run a test ad-hoc command using an inventory file
```
ansible -i inventory/hosts.yml ubuntu_cloud -a "hostname"
```
Create an alias called `vvans` (can be any name) to make things convenient
```sh
echo 'alias vvans="ansible-playbook -i inventory/hosts.yml --vault-password-file ~/.ansible/vault_pw.txt"' >> ~/.bashrc
source ~/.bashrc
```
# Starting from "Ground Zero" (and Going Back)
## Create VMs
To create the VMs, need to run Ubuntu (WSL) as Administrator. Run all commands from the ansible directory: `~/hyper-homelab/ansible/`
```sh
ansible-playbook provision.yml -i inventory/hosts.yml --vault-password-file ~/.ansible/vault_pw.txt
```
 ## Configure VMs
 ```sh
 # might need to run one (or both) of these twice, due to reboot
 ansible-playbook base-os.yml -i inventory/hosts.yml --vault-password-file ~/.ansible/vault_pw.txt
 # even though the gui.yml playbook currently doesn't use the vars that are encrypted, still need to decrypt to avoid error
 ansible-playbook gui.yml -i inventory/hosts.yml --vault-password-file ~/.ansible/vault_pw.txt
```
At this point all of the virtual machines will have a GUI installed. From there, run `playbook-bitcoin` and `playbook-dotnet` as appropriate.
## Delete VMs
Need to use PowerShell as Administrator
```ps1
D:\VMs\27-destroy.ps1
D:\VMs\28-destroy.ps1
```
## Bitcoin
This shows the output of bitcoind
```
journalctl -f -u btc.service
```



## Ansible Vault
```
ansible-vault encrypt inventory/group_vars/all/vault.yml --vault-password-file ~/.ansible/vault_pw.txt
ansible-vault view inventory/group_vars/all/vault.yml --vault-password-file ~/.ansible/vault_pw.txt
ansible-vault edit inventory/group_vars/all/vault.yml --vault-password-file ~/.ansible/vault_pw.txt
```
