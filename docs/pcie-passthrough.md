

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



cat /proc/iomem


initcall_blacklist=sysfb_init




BIOS F4403 (AGESA V2 PI 1.2.0.7): enable IOMMU, SVM; disable CSM



# Attempt 4
## Configure Motherboard BIOS
Passthrough (AMD-Vi / Intel VT-d)
- Advanced > AMD CBS > NBIO Common Options > IOMMU = Enable

Virtualization (AMD-V / Intel VT-x)
- Advanced > CPU Configuration >  SVM Mode = Enable

Boot Options
- Boot > CSM = Disable

## Enable vfio Kernel Modules
```sh
# lsmod | grep vfio
<no output>
# nano /etc/modules
# printf " vfio \n vfio_iommu_type1 \n vfio_pci \n vfio_virqfd \n" >> /etc/modules
< ... >
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

## Create Script to Check IOMMU Groups
Create a script file called `getgroups.sh`. Make it executable.
```sh
#!/bin/bash
shopt -s nullglob
for d in /sys/kernel/iommu_groups/*/devices/*; do
    n=${d#*/iommu_groups/*}; n=${n%%/*}
    printf 'IOMMU Group %s ' "$n"
    lspci -nns "${d##*/}"
done | sort -V
```
## Identify PCI Devices to Pass Through
```sh
# ./getgroups.sh
IOMMU Group 2 00:03.0 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Starship/Matisse PCIe Dummy Host Bridge [1022:1482]
IOMMU Group 2 00:03.1 PCI bridge [0604]: Advanced Micro Devices, Inc. [AMD] Starship/Matisse GPP Bridge [1022:1483]
IOMMU Group 2 07:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU104 [GeForce RTX 2060] [10de:1e89] (rev a1)
IOMMU Group 2 07:00.1 Audio device [0403]: NVIDIA Corporation TU104 HD Audio Controller [10de:10f8] (rev a1)
IOMMU Group 2 07:00.2 USB controller [0c03]: NVIDIA Corporation TU104 USB 3.1 Host Controller [10de:1ad8] (rev a1)
IOMMU Group 2 07:00.3 Serial bus controller [0c80]: NVIDIA Corporation TU104 USB Type-C UCSI Controller [10de:1ad9] (rev a1)
<...>
IOMMU Group 14 09:00.3 USB controller [0c03]: Advanced Micro Devices, Inc. [AMD] Matisse USB 3.0 Host Controller [1022:149c]
```

## Specify PCI Devices to Pass Through
```sh
# lspci -nnk | grep -B 2 -A 1 vfio
<no output>
# echo "options vfio-pci ids=10de:1e89,10de:10f8,10de:1ad8,10de:1ad9,1022:149c" > /etc/modprobe.d/vfio.conf
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

## Disable Frame Buffers
```sh
# cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-5.15.64-1-pve root=/dev/mapper/pve-root ro quiet
# nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet initcall_blacklist=sysfb_init"
# grub-mkconfig -o /boot/grub/grub.cfg
# reboot
# cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-5.15.64-1-pve root=/dev/mapper/pve-root ro quiet initcall_blacklist=sysfb_init
```

## Create VM
Use Windows 11 ISO (22H2v1)  
All defaults, except:
- Increase size of disk to 52GB
- Use 2 cores

Add PCI Device (Graphics)
- All Functions = Y
- Primary GPU = Y
- PCI-Express = Y

Add PCI Device (USB)
- All Defaults

# Troubleshooting
✅ The only visible entries in the boot log should be:
```
Loading Linux 5.15.64-1-pve ...
Loading initial ramdisk ...
```
⚠️ If boot the log ends past `Loading initial ramdisk ...`, frame buffer capabilities are probably still enabled.
```sh
# -- before disabling frame buffers
Found volume group "pve" using metadata type lvm2
6 logical volume(s) in volume group "pve" now active
/dev/mapper/pve-root: clean, nn/nn files, nn/nn blocks
# nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet initcall_blacklist=sysfb_init"
# grub-mkconfig -o /boot/grub/grub.cfg
# reboot
# -- after disabling frame buffers
Loading Linux 5.15.64-1-pve ...
Loading initial ramdisk ...
```


⚠️ Devices we don't want to pass CANNOT be in the same IOMMU group.
❓Should I pass the PCIe bridges? NO
❓Should I pass the USB functions to vfio-pci ids? Not sure of the impact there.

💡Comparing `lspci` output before and after the VM starts would be helpful. It seems like the GPU+HD audio device START as passthrough, while others are normal (owned by host) until the VM starts.


# References
Command List
```sh
# making changes
nano /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
echo "options vfio-pci ids=10de:1e89,10de:10f8,10de:1ad8,10de:1ad9 disable_vga=1" > /etc/modprobe.d/passthrough.conf
update-initramfs -u -k all

# validating
lsmod | grep vfio
dmesg | grep -e DMAR -e IOMMU -e AMD-Vi
lspci -nnk | grep -B 2 -A 1 vfio
cat /proc/cmdline
sysctl -a | grep video # not 1:1 naming with passed parameters



```


[Spaceinvader One: A little about Passthrough, PCIe, IOMMU Groups and breaking them up](https://www.youtube.com/watch?v=qQiMMeVNw-o)

[welemmanuel: Working Config](https://forum.proxmox.com/threads/problem-with-gpu-passthrough.55918/post-486436)




printf " vfio \n vfio_iommu_type1 \n vfio_pci \n vfio_virqfd \n"