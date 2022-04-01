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

## Delete VMs
```
pvesh create /nodes/pve4/qemu/102/status/stop
pvesh delete /nodes/pve4/qemu/102 --destroy-unreferenced-disks 1 --purge 1
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
