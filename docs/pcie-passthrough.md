# PCIe Passthrough
https://pve.proxmox.com/wiki/PCI(e)_Passthrough


Enable IOMMU in Motherboard BIOS
- Advanced > AMD CBS > NBIO Common Options


```sh
# nano /etc/modules
...
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
# update-initramfs -u -k all
update-initramfs: Generating /boot/initrd.img-5.15.64-1-pve
Running hook script 'zz-proxmox-boot'..
Re-executing '/etc/kernel/postinst.d/zz-proxmox-boot' in new private mount namespace..
No /etc/kernel/proxmox-boot-uuids found, skipping ESP sync.
update-initramfs: Generating /boot/initrd.img-5.15.30-2-pve
Running hook script 'zz-proxmox-boot'..
Re-executing '/etc/kernel/postinst.d/zz-proxmox-boot' in new private mount namespace..
No /etc/kernel/proxmox-boot-uuids found, skipping ESP sync.
# reboot
# dmesg | grep -e DMAR -e IOMMU -e AMD-Vi
[    0.680418] pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
[    0.683153] pci 0000:00:00.2: AMD-Vi: Found IOMMU cap 0x40
[    0.683156] AMD-Vi: Extended features (0x58f77ef22294a5a): PPR NX GT IA PC GA_vAPIC
[    0.683160] AMD-Vi: Interrupt remapping enabled
[    0.693138] perf/amd_iommu: Detected AMD IOMMU #0 (2 banks, 4 counters/bank).
```

Look for the PCI (slot?) numbers associated with NVIDIA devices.

With card in secondary x16 slot
```sh
# lspci -nn
04:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU104 [GeForce RTX 2060] [10de:1e89] (rev a1)
04:00.1 Audio device [0403]: NVIDIA Corporation TU104 HD Audio Controller [10de:10f8] (rev a1)
04:00.2 USB controller [0c03]: NVIDIA Corporation TU104 USB 3.1 Host Controller [10de:1ad8] (rev a1)
04:00.3 Serial bus controller [0c80]: NVIDIA Corporation TU104 USB Type-C UCSI Controller [10de:1ad9] (rev a1)
```

With card in primary x16 slot
```sh
# lspci -nn
07:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU104 [GeForce RTX 2060] [10de:1e89] (rev a1)
07:00.1 Audio device [0403]: NVIDIA Corporation TU104 HD Audio Controller [10de:10f8] (rev a1)
07:00.2 USB controller [0c03]: NVIDIA Corporation TU104 USB 3.1 Host Controller [10de:1ad8] (rev a1)
07:00.3 Serial bus controller [0c80]: NVIDIA Corporation TU104 USB Type-C UCSI Controller [10de:1ad9] (rev a1)
```

Determine which IOMMU groups the NVIDIA devices are in. See if there are any other devices in that group.

With card in secondary x16 slot
- They are in group 0
- Lots of other devices are in that same group
- Including Ethernet and NVMe drives
- **⚠️⚠️⚠️ ISSUE: THE DEVICE SHOULD BE THE ONLY ONE IN THE GROUP ⚠️⚠️⚠️**

With card in primary GPU slot
❓Should I pass the PCIe bridges?
```sh
# find /sys/kernel/iommu_groups/ -type l
# plus some excel forumulas to associate devices by group...
2	00:03.0	Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Starship/Matisse PCIe Dummy Host Bridge [1022:1482]
2	00:03.1	PCI bridge [0604]: Advanced Micro Devices, Inc. [AMD] Starship/Matisse GPP Bridge [1022:1483]
2	07:00.0	VGA compatible controller [0300]: NVIDIA Corporation TU104 [GeForce RTX 2060] [10de:1e89] (rev a1)
2	07:00.1	Audio device [0403]: NVIDIA Corporation TU104 HD Audio Controller [10de:10f8] (rev a1)
2	07:00.2	USB controller [0c03]: NVIDIA Corporation TU104 USB 3.1 Host Controller [10de:1ad8] (rev a1)
2	07:00.3	Serial bus controller [0c80]: NVIDIA Corporation TU104 USB Type-C UCSI Controller [10de:1ad9] (rev a1)
```

- **⚠️⚠️⚠️ There was a typo in the IDs the first round. not sure if that was this doc only or also the real file contents ⚠️⚠️⚠️**
```sh
# echo "options vfio-pci ids=10de:1e89,10de:10f8,10de:1ad8,10de:1ad9" > /etc/modprobe.d/passthrough.conf
# update-initramfs -u -k all
update-initramfs: Generating /boot/initrd.img-5.15.64-1-pve
Running hook script 'zz-proxmox-boot'..
Re-executing '/etc/kernel/postinst.d/zz-proxmox-boot' in new private mount namespace..
No /etc/kernel/proxmox-boot-uuids found, skipping ESP sync.
update-initramfs: Generating /boot/initrd.img-5.15.30-2-pve
Running hook script 'zz-proxmox-boot'..
Re-executing '/etc/kernel/postinst.d/zz-proxmox-boot' in new private mount namespace..
No /etc/kernel/proxmox-boot-uuids found, skipping ESP sync.
```

After rebooting, it *seems* to work. The boot log stops as soon as the lvm vgs are checked.

I can still ssh into the machine and also access the web interface.


📝 only the VGA controller uses the driver (not the related functions)
```sh
# lspci -nnk | grep -C 2 vfio
04:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU104 [GeForce RTX 2060] [10de:1e89] (rev a1)
        Subsystem: eVga.com. Corp. TU104 [GeForce RTX 2060] [3842:2068]
        Kernel driver in use: vfio-pci
        Kernel modules: nvidiafb, nouveau

```

📝 With typos fixed, one more device uses the vfio stuff
```sh
#lspci -nnk | grep -B 2 -A 1 vfio
07:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU104 [GeForce RTX 2060] [10de:1e89] (rev a1)
        Subsystem: eVga.com. Corp. TU104 [GeForce RTX 2060] [3842:2068]
        Kernel driver in use: vfio-pci
        Kernel modules: nvidiafb, nouveau
07:00.1 Audio device [0403]: NVIDIA Corporation TU104 HD Audio Controller [10de:10f8] (rev a1)
        Subsystem: eVga.com. Corp. TU104 HD Audio Controller [3842:2068]
        Kernel driver in use: vfio-pci
        Kernel modules: snd_hda_intel

```

create windows vm with defaults

```sh
# qm set 100 -hostpci0 04:00.0
update VM 100: -hostpci0 04:00.0
```

second round - this time I excluded the last part of the pcie address
```sh
# qm set 100 -hostpci0 07:00,pcie=on,x-vga=on
update VM 100: -hostpci0 07:00,pcie=on,x-vga=on
```

now the device appears in the gui
- checked primary GPU
- checked PCIe

⛔ The screen goes blank, connection to host SSH and web interface are lost ⛔

tried using PCI instead of PCIe

⛔ The screen goes blank, connection to host SSH and web interface are lost ⛔


after the second attempt: at least proxmox doesn't crash!!
machine gets stuck on a black screen with a blinking white cursor on the top left.

looks like a button needs to be pushed to boot from cd

tried disabling other boot options - same result

booted using the regular console - pressed enter really fast

that worked. got into the windows installer

needed to change the default disk size from 32GB to 52GB because the installer complained that 52 was the minumum

installed windows using the regular console.

rebooted.

same result - blinking cursor at top left of screen





⛔ Okay, so after all of this: Things don't crash, but the GPU still doesn't get fully transferred to the VM ⛔

Exactly like the forum post states, I can still login to Proxmox.


https://forum.proxmox.com/threads/gpu-passthrough-windows-11-blinking-cursor.106782/

OP got things running like this:
```sh
# old
GRUB_CMDLINE_LINUX_DEFAULT="quiet ... video=efifb:eek:ff"
# new
GRUB_CMDLINE_LINUX_DEFAULT="quiet ... video=efifb:off"
```

EFI Frame Buffer
https://passthroughpo.st/explaining-csm-efifboff-setting-boot-gpu-manually/
For GPU Passthrough, you do not want anything using the guest card. For this reason, you will need to add a kernel command-line parameter to disable the EFI/VESA framebuffer.




My system:
```sh
# old
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
# new
GRUB_CMDLINE_LINUX_DEFAULT="quiet video=efifb:off"
# update
grub-mkconfig -o /boot/grub/grub.cfg
# reboot
```

found this script to avoid the need to use excel to connect devices to groups
```
#!/bin/bash
shopt -s nullglob
for d in /sys/kernel/iommu_groups/*/devices/*; do
    n=${d#*/iommu_groups/*}; n=${n%%/*}
    printf 'IOMMU Group %s ' "$n"
    lspci -nns "${d##*/}"
done | sort -V
```

📝 binding to driver - exclude bridges
📝 most people seem to only include the VGA controller and the HD audio controller
📝 most people seem to use the syntax vfio-pcie.ids instead of "vfio-pcie ids"
WAIT - that's because kernel parameters are being specified in grub, as opposed to the modprobe file
```
vfio-pic.ids=
```


per arch wiki
"You should also append the iommu=pt parameter. This will prevent Linux from touching devices which cannot be passed through."
however, it seems like this is related to older stuff.
https://wiki.archlinux.org/title/Talk:PCI_passthrough_via_OVMF#intel_iommu_kernel_parameter_might_no_be_necessary_on_some_systems
"but this may cause problems on some older platforms"

"Note: If they are grouped with other devices in this manner, pci root ports and bridges should neither be bound to vfio at boot, nor be added to the virtual machine."
do not include ports and bridges, nor bind them to the VM

Starting with Linux 4.1, the kernel includes vfio-pci.

Binding the audio device (10de:0fbb in above's example) is optional. Libvirt is able to unbind it from the snd_hda_intel driver on its own

This line adjusts KERNEL PARAMETERS
since the kernel now includes vfio-pci, the directions on the Proxmox wiki that basically end up rebuilding the kernel SHOULDN'T? be required.
The "Loading vfio-pci early" has a setp that adds the exact same modules to mkinitcpio.conf. unsure if the proxmox documentation setps do that or not.

```
lsmod | grep vfio
```

GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
grub-mkconfig -o /boot/grub/grub.cfg


MY MACHINE
```
[37062.990130] vfio-pci 0000:07:00.0: BAR 1: can't reserve [mem 0xd0000000-0xdfffffff 64bit pref]
```




"It is not necessary for all devices (or even expected device) from vfio.conf to be in dmesg output. Even if a device does not appear, it might still be visible and usable in the guest virtual machine."

```
$ lspci -nnk -d 10de:13c2
06:00.0 VGA compatible controller: NVIDIA Corporation GM204 [GeForce GTX 970] [10de:13c2] (rev a1)
	Kernel driver in use: vfio-pci
	Kernel modules: nouveau nvidia
```

# Attempt 2 Log

Last visible entry in the log:
```
/dev/mapper/pve-root: clean, ...
```
```sh
# dmesg | grep -i vfio
[    5.580531] VFIO - User Level meta-driver version: 0.3
[    5.585508] vfio-pci 0000:07:00.0: vgaarb: changed VGA decodes: olddecodes=io+mem,decodes=io+mem:owns=none
[    5.609068] vfio_pci: add [10de:1e89[ffffffff:ffffffff]] class 0x000000/00000000
[    5.629140] vfio_pci: add [10de:10f8[ffffffff:ffffffff]] class 0x000000/00000000
[    5.629150] vfio_pci: add [10de:1ad8[ffffffff:ffffffff]] class 0x000000/00000000
[    5.629156] vfio_pci: add [10de:1ad9[ffffffff:ffffffff]] class 0x000000/00000000
```
```sh
# lspci -nnk | grep -B 2 -A 1 vfio
07:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU104 [GeForce RTX 2060] [10de:1e89] (rev a1)
        Subsystem: eVga.com. Corp. TU104 [GeForce RTX 2060] [3842:2068]
        Kernel driver in use: vfio-pci
        Kernel modules: nvidiafb, nouveau
07:00.1 Audio device [0403]: NVIDIA Corporation TU104 HD Audio Controller [10de:10f8] (rev a1)
        Subsystem: eVga.com. Corp. TU104 HD Audio Controller [3842:2068]
        Kernel driver in use: vfio-pci
        Kernel modules: snd_hda_intel
```
Try and start VM
```sh
# dmesg | grep -i vfio
#... TONS of the same error
[  511.005586] vfio-pci 0000:07:00.0: BAR 1: can't reserve [mem 0xd0000000-0xdfffffff 64bit pref]
[  511.005594] vfio-pci 0000:07:00.0: BAR 1: can't reserve [mem 0xd0000000-0xdfffffff 64bit pref]
```
try removing bar checkmark from advanced optons in GUI
- no output to display at all
```sh
# dmesg | grep -i vfio
# only a few messages this time
[  653.553001] vfio-pci 0000:07:00.0: vfio_ecap_init: hiding ecap 0x1e@0x258
[  653.553029] vfio-pci 0000:07:00.0: vfio_ecap_init: hiding ecap 0x19@0x900
[  653.554152] vfio-pci 0000:07:00.0: BAR 1: can't reserve [mem 0xd0000000-0xdfffffff 64bit pref]
```
```sh
# nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on nomodeset video=vesafb:off video=efifb:off"
# grub-mkconfig -o /boot/grub/grub.cfg
# reboot
```
"Adding the nomodeset parameter instructs the kernel to not load video drivers and use BIOS modes instead until X is loaded."

➡️ Boot log is same  
➡️ dmesg is same (before VM start)  
➡️ lspci is same (before VM start)  
➡️ dmesg is same as original test with rombar at default - 1000s of messages (after VM start)  
➡️ dmesg is same as original test with rombar at disabled - 3 messages (after VM start)
```sh
# nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet nomodeset video=vesafb:off video=efifb:off"
# grub-mkconfig -o /boot/grub/grub.cfg
# reboot
```
➡️ Boot log is same  
➡️ dmesg is same (before VM start)  
➡️ lspci is same  

```sh
# cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-5.15.64-1-pve root=/dev/mapper/pve-root ro quiet video=vesafb:off video=efifb:off
# sysctl -a | grep video
kernel.acpi_video_flags = 0
```
```sh
# nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet video=efifb:off,vesafb:off"
# grub-mkconfig -o /boot/grub/grub.cfg
# reboot
```
➡️ Boot log is same  
➡️ dmesg is same (before VM start)  
➡️ lspci is same  
```sh
# cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-5.15.64-1-pve root=/dev/mapper/pve-root ro quiet video=efifb:off,vesafb:off
# sysctl -a | grep video
kernel.acpi_video_flags = 0
```


```sh
# echo "options vfio-pci ids=10de:1e89,10de:10f8" > /etc/modprobe.d/passthrough.conf
# update-initramfs -u -k all
# reboot
```

iommu=pt

```sh
# echo "options vfio-pci ids=10de:1e89,10de:10f8,10de:1ad8,10de:1ad9 disable_vga=1" > /etc/modprobe.d/passthrough.conf
# update-initramfs -u -k all
```
➡️ Boot log is same  
➡️ lspci is same (before VM start)  
➡️ dmesg is same as original test with rombar at default - 1000s of messages (after VM start)  

pcie to pci - no difference

## Attempt 3
Motherboard BIOS
- Advanced > AMD CBS > NBIO Common Options > Enable IOMMU
- Boot > Disable CSM
### Kernel modules for vfio are running.
```sh
# lsmod | grep vfio
<no output>
# nano /etc/modules
...
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
# update-initramfs -u -k all
# reboot
# lsmod | grep vfio
vfio_pci               16384  0
vfio_pci_core          73728  1 vfio_pci
vfio_virqfd            16384  1 vfio_pci_core
irqbypass              16384  2 vfio_pci_core,kvm
vfio_iommu_type1       40960  0
vfio                   45056  2 vfio_pci_core,vfio_iommu_type1
# dmesg | grep -e DMAR -e IOMMU -e AMD-Vi
[    0.680418] pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
[    0.683153] pci 0000:00:00.2: AMD-Vi: Found IOMMU cap 0x40
[    0.683156] AMD-Vi: Extended features (0x58f77ef22294a5a): PPR NX GT IA PC GA_vAPIC
[    0.683160] AMD-Vi: Interrupt remapping enabled
[    0.693138] perf/amd_iommu: Detected AMD IOMMU #0 (2 banks, 4 counters/bank).
```
### Specify devices and disable vga
```sh
# lspci -nnk | grep -B 2 -A 1 vfio
<no output>
# echo "options vfio-pci ids=10de:1e89,10de:10f8,10de:1ad8,10de:1ad9 disable_vga=1" > /etc/modprobe.d/passthrough.conf
# update-initramfs -u -k all
# reboot
# lspci -nnk | grep -B 2 -A 1 vfio
07:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU104 [GeForce RTX 2060] [10de:1e89] (rev a1)
        Subsystem: eVga.com. Corp. TU104 [GeForce RTX 2060] [3842:2068]
        Kernel driver in use: vfio-pci
        Kernel modules: nvidiafb, nouveau
07:00.1 Audio device [0403]: NVIDIA Corporation TU104 HD Audio Controller [10de:10f8] (rev a1)
        Subsystem: eVga.com. Corp. TU104 HD Audio Controller [3842:2068]
        Kernel driver in use: vfio-pci
        Kernel modules: snd_hda_intel
```
### Start GRUB without Video
```sh
# nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet video=efifb:off video=vesafb:off video=simplefb:off"
# grub-mkconfig -o /boot/grub/grub.cfg
# reboot
```
➡️ Stops SLIGHTLY earlier in the boot log. Stops at "Loading initial ramdisk..."
➡️ dmesg is same as original test with rombar at default - 1000s of messages (after VM start)  



echo 1 > /sys/bus/pci/devices/0000\:09\:00.0/remove
echo 1 > /sys/bus/pci/rescan

0000:07:00.0

echo 1 > /sys/bus/pci/devices/0000\:07\:00.0/remove


The command line defaults ARE reequired.
When not passed, there was a crazy situation where I could see both the VM boot screen AND the Proxmox prompt at the same time.
