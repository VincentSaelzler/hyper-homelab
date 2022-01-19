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
> ⚠️ WARNING: Remove all VMs from a node before uninstalling Proxmox! Also, remove nodes from the cluster **before** re-installing Proxmox.  

Also try and remember to remove before uninstalling Proxmox, although that's not required as long as you can rmember the name of the node.
```sh
pvecm nodes # ran AFTER pve4 was powered down, so name is missing from output.

Membership information
----------------------
    Nodeid      Votes Name
         2          1 pve2
         3          1 pve3
         4          1 pve5 (local)
```
Remove the node.
```sh
pvecm delnode pve4
Could not kill node (error = CS_ERR_NOT_EXIST) #this is fine
Killing node 1
root@pve5:~# 
```
