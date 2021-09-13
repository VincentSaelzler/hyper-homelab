Connect to a VirtualBox-based guest with default networking
```
ssh vagrant@127.0.0.1 -p 2222
```
Run a test ad-hoc command using an inventory file
```
ansible -i hosts.yml vagrantboxes -a "hostname"
```
Run a playbook using an inventory file
```
vince@5480:~/src/hyper-homelab/localdev$ ansible-playbook playbooks/bootstrap.yml -i hosts.yml  
```