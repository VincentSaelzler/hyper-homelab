# Install Wizard (Manual)
Unlike most of the other infrastructure (VMs), the Proxmox OS is installed on bare metal hardware. This requires some manual commands and data entry.
## Disk Prep
### 1. Remove LVM Stuff:
If there are any other LVM things on the disk(s), the Proxmox installer fails. Here are some relevant commands to remove the LVM stuff.
```
lvs
lvremove
vgs
vgremove
pvs
pvremove
```
### 2. Clear Partition Tables
**After** LVM stuff has been wiped, clear partition tables. Repeat this command for each disk.
```
sgdisk /dev/sdx --zap-all
```
## General Configuration
*Once LVM and partitions are gone*, we can move on to the install.

Some basic details about the node need to be manually entered, including:
- (temporary) Password
- IP Address
- Gateway and DNS
- Domain

The PW is set to `easypass` initially, then changed by Ansible.

## Cluster Creation and Joining
> ⚠️ WARNING: Remove nodes from the cluster **before** uninstalling or re-installing Proxmox.
### Manual Join
This is (unfortunately) the way it needs to be done.

The main problem with automated is that all methods require the root PW of an existing node to be entered interactviely.

- Datacenter > Cluster > Create Cluster (first node)
- Datacenter > Cluster > Join Information (any node in cluster already)
- Datacenter > Cluster > Join Cluster (new node)
### Troubles Faced when Using Ansible
Creating the cluster seems to work just fine.
```
root@pve2 pvecm create cluster0
```

However, adding a node to an existing cluter is more difficult. The core of the issue is authenticating on the existing cluster node from the new node that's joining the cluster.
```sh
root@pve3 pvecm add 192.168.128.2 #asks for PW interactively
```
The alternative to using (non-scriptable) PW authentication is the `--use_ssh` flag of the join command. However, that requires pre-configuring the public *and* private keys on the server.
```sh
root@pve3 pvecm add 192.168.128.2 --use_ssh
```
When the interactive PW prompt is triggered from within Ansible, it requires pusing `control-c` to unfreeze the process. This leads to messed up SSH configurations. I can no longer ssh into `pve3` from another machine (or Ansible!).
```sh
root@pve3:~/.ssh ls -l
total 16
lrwxrwxrwx 1 root root       29 Dec 20 19:18 authorized_keys -> /etc/pve/priv/authorized_keys #this is a partially complete configuration which omits the ansible keys
-rw------- 1 root www-data  569 Dec 20 19:15 authorized_keys.org #these are the old keys that ansible installed
```
