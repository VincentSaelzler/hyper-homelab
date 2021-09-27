#!/bin/bash

# constants
vhd_dir="/mnt/c/Users/Public/Documents/Hyper-V/Virtual hard disks/"

arch_url="https://gitlab.archlinux.org/archlinux/arch-boxes/-/jobs/34904/artifacts/raw/output/Arch-Linux-x86_64-cloudimg-20210923.0.qcow2"
arch_file="arch.qcow2"

focal_url="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
focal_file="focal.img"

# download os image file 
#wget $arch_url -O $arch_file
#wget $focal_url -O $focal_file

# -- per machine
vm_id="27"
# convert and copy image to windows dir
#qemu-img convert $arch_file -O vhdx "$vhd_dir$vm_id"-os.vhdx
#qemu-img convert $focal_file -O vhdx "$vhd_dir$vm_id"-os.vhdx
#qemu-img convert $arch_file -O vpc "$vhd_dir$vm_id"-os.vhd

# generate seed iso and save in windows dir
# ok having the PW here because it's just a test
# ultimately will only be configuring public keys and IP addrs with cloud-init
# those are ok in plain text
cat > user-data <<EOF
#cloud-config
password: asdfjkl;
chpasswd: { expire: False }
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCW4Cf2kYGSvvx+HYcxs3dy4LGZ5At4+7out4usw0xY+lKlbMI5Y+tn62//3uCgDJ7zwMpq9gLOVdQ3XXdtri9e1DWIpytv26BR/RQOfslXeRw+GhVqMYsSd1Y5i9AqvDhSZN1zOA/Gq7EdGT7EGAuPfX+iehAhFXOWDOpIzWyFunMWDinYwrKesYwqLtfVREMa+8GWIijN8usGs9i4ZSdtrUDv7Lgyn9AAfpNiGu+QicYVkTbsXUwSjVmCNggX50qZvp4KuUUq5vStm5RQCRkB07fJQxR3StqMGikK60gSyWRXPxLsFsglet2WmA/4y7sGPlI3WPCFJYFM2VESVo8EMsssKAuo20MrCC8Fs2hcCpqPyBI4Las8drZ8WcWNf5Vht8FFBq7KvFySIyrvv5tD6nWok7tL3PGkDsamTAMdVTxbxLkAowo/ta31jWk3sdRHwyi8B2JrlbdGoTA73E3yhMOOA5UWbd2Si+Ykk6vwFXdzO2y7UR8ChjCiXE/U6JE= vince@RYZEN
EOF

cat > network-config <<EOF
version: 2
ethernets:
  eth0:
    addresses:
      - 192.168.1.27/255.255.255.0
EOF

cat > meta-data <<EOF
instance-id: iid-abcdefg
network-interfaces: |
  iface eth0 inet static
  address 192.168.1.27
  network 192.168.1.0
  netmask 255.255.255.0
  broadcast 192.168.1.255
  gateway 192.168.1.254
hostname: myhost
EOF

cloud-localds "$vhd_dir$vm_id"-seed.iso user-data meta-data #-N network-config

rm network-config user-data meta-data

# copy to the windows dir so we can start an elevated command prompt
# (manually for now)
ps_create="CreateVm.ps1"
ps_delete="DeleteVm.ps1"
cp $ps_create $ps_delete "$vhd_dir"


