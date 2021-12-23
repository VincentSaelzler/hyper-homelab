#!/bin/bash

## pve4
## be sure to do --zap-all (not just --zap) to remove GPT ~AND~ MBR stuff
## the partition seems to start on sector 2048, even without the alignment option
## the partition table seems to be implicitly created

sgdisk /dev/sda --zap-all
sgdisk /dev/sda --largest-new=1 --typecode=1:8e00 --change-name=1:"Linux LVM"