# Manual Steps
## Install Wizard
Unlike the other infrastructure (VMs), the Proxmox OS is installed on bare metal hardware.

Some of the steps are manual, while others can be completed using Ansible.

All of the basic details about the node need to be manually entered via the installer menu.

Some important ones:
- Password
- IP Address
- Gateway and DNS
- Domain

The PW is set to `easypass` initially, then changed by Ansible.

## Disk Prep
If there are any other LVM things on the disk(s), the Proxmox installer fails. Here are some relevant commands to remove the LVM stuff.
```
lvs
lvremove
vgs
vgremove
pvs
pvremove
```
**After*** LVM stuff has been wiped, clear partition tables using these commands. The `gdisk` commands need to be run individually and interactively for each disk.
```
gdisk /dev/sdx
x, z, y, y (extra, zap, yes remove GPT, yes remove BIOS fallback)
pvremove /dev/sda /dev/sdb /dev/sd.. -f
```
## Cluster Creation (or Joining)


