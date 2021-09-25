#!/bin/bash

# constants
vhd_dir="/mnt/c/Users/Public/Documents/Hyper-V/Virtual hard disks/"

arch_url="https://gitlab.archlinux.org/archlinux/arch-boxes/-/jobs/34904/artifacts/raw/output/Arch-Linux-x86_64-cloudimg-20210923.0.qcow2"
arch_file="arch.qcow2"

# download os image file 
#wget $arch_url -O $arch_file

# -- per machine
vm_id="27"
# convert and copy image to windows dir
qemu-img convert $arch_file -O vhdx "$vhd_dir$vm_id"-os.vhdx

# generate seed iso and save in windows dir
# ok having the PW here because it's just a test
# ultimately will only be configuring public keys and IP addrs with cloud-init
# those are ok in plain text
cat > user-data <<EOF
#cloud-config
password: password$vm_id
chpasswd: { expire: False }
EOF

cloud-localds "$vhd_dir$vm_id"-seed.iso user-data

# copy to the windows dir so we can start an elevated command prompt
# (manually for now)
ps_create="CreateVm.ps1"
ps_delete="DeleteVm.ps1"
cp $ps_create $ps_delete "$vhd_dir"


