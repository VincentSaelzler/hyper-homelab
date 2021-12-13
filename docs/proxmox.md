# Installed on Bare Metal
Unlike the other infrastructure (all VMs) this needs to be done on bare metal hardware.

# Disk Prep
If there are any other LVM things on the disk(s), the Proxmox installer fails.

Clear disks first with these commands:
```
sgdisk /dev/sda /dev/sdb /dev/sd.. --zap
pvremove /dev/sda /dev/sdb /dev/sd.. -f
```

# Data Entry
All of the basic details about the node need to be manually entered via the installer menu.

Some important ones:
- Password
- IP Address
- Gateway and DNS
- Domain

The PW is set to something easy to type initially, then changed by Ansible.

