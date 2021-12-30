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
Run all Ansible commands from the `ansible` directory: `~/hyper-homelab/ansible/`

## Create VMs
To create the VMs, need to run Ubuntu (WSL) **as Administrator**. 
```sh
vvans provision.yml
```

 ## Configure VMs
 These commands are all **idempotent**!
 ```sh
 # these will fully set up the hosts
vvans dotnet.yml
vvans bitcoin.yml
# for experimentation purposses, the hosts can be stopped at a partial configuration state
vvans base-os.yml
vvans gui.yml
```

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
