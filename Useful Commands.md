Connect to a VirtualBox-based guest with default networking
```
ssh vagrant@127.0.0.1 -p 2222
```
Run a test ad-hoc command using an inventory file
```
ansible -i hosts.yml vagrantboxes -a "hostname"
```
Run a playbook using an inventory file, and with verbosity
```
ansible-playbook ~/hyper-homelab/ansible/playbook-local.yml -i ~/hyper-homelab/ansible/inventory.yml -v
```
Current Process of Starting from "Ground Zero"
```sh
 ansible-playbook ~/hyper-homelab/ansible/playbook-provision.yml -i ~/hyper-homelab/ansible/inventory.yml
 # need to run twice due to reboot
 ansible-playbook ~/hyper-homelab/ansible/playbook-base-os.yml -i ~/hyper-homelab/ansible/inventory.yml
 ansible-playbook ~/hyper-homelab/ansible/playbook-gui.yml -i ~/hyper-homelab/ansible/inventory.yml
```
At this point all of the virtual machines will have a GUI installed. From there, run `playbook-bitcoin` and `playbook-dotnet` as appropriate.