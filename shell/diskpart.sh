#!/bin/bash

## pve4
## be sure to do --zap-all (not just --zap) to remove GPT ~AND~ MBR stuff
## the partition seems to start on sector 2048, even without the alignment option
## the partition table seems to be implicitly created

sgdisk /dev/sda --zap-all
sgdisk /dev/sda --largest-new=1 --typecode=1:8e00 --change-name=1:"Linux LVM"

##pve5
## starting out, there are LVMs in sdc and sdd
## getting complaints about duplicate vg name (pve)
sgdisk /dev/sdb --zap-all
sgdisk /dev/sdc --zap-all
sgdisk /dev/sdd --zap-all
sgdisk /dev/sde --zap-all
#reboot
#sweet - no lvm info found on reboot
sgdisk /dev/sdb --new=1:0:+232G --typecode=1:fd00 --change-name=1:"Linux RAID"
sgdisk /dev/sdc --new=1:0:+232G --typecode=1:fd00 --change-name=1:"Linux RAID"
sgdisk /dev/sdd --new=1:0:+232G --typecode=1:fd00 --change-name=1:"Linux RAID"
sgdisk /dev/sde --new=1:0:+232G --typecode=1:fd00 --change-name=1:"Linux RAID"

apt install mdadm

mdadm --create --verbose --level=0 --raid-devices=4 /dev/md0 /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1
## there's a warning but it still seems to work
## mdadm: partition table exists on /dev/sd[bcde]1 but will be lost or meaningless after creating array

mkfs.ext4 -v -L quad -b 4096 -E stride=128,stripe-width=512 /dev/md0

