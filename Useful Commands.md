# General Ansible Stuff
Run a test ad-hoc command using an inventory file
```
ansible -i inventory/hosts.yml ubuntu_cloud -a "hostname"
```
# Starting from "Ground Zero" (and Going Back)
## Create VMs
To create the VMs, need to run Ubuntu (WSL) as Administrator. Run all commands from the ansible directory: `~/hyper-homelab/ansible/`
```sh
ansible-playbook ~/hyper-homelab/ansible/playbook-provision.yml -i ~/hyper-homelab/ansible/inventory.yml
 ```
 ## Configure VMs
 ```sh
 # need to run twice due to reboot
 ansible-playbook base-os.yml -i inventory/hosts.yml
 ansible-playbook gui.yml -i inventory/hosts.yml
```
At this point all of the virtual machines will have a GUI installed. From there, run `playbook-bitcoin` and `playbook-dotnet` as appropriate.
## Delete VMs
Need to use PowerShell as Administrator
```ps1
D:\VMs\27-destroy.ps1
D:\VMs\28-destroy.ps1
```
# Bitcoin
This shows the output of bitcoind
```
journalctl -f -u btc.service
```