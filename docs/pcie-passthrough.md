# Working Configuration
## Configure Motherboard BIOS
Enable IOMMU and Virtualization. Disable Legacy Boot.
- IOMMU = Enable (Advanced > AMD CBS > NBIO Common Options)
- SVM Mode = Enable (Advanced > CPU Configuration)
- CSM = Disable (BOOT?)

## Enable vfio Kernel Modules
```sh
# lsmod | grep -i vfio
<no output>
# nano /etc/modules
< ... >
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
# update-initramfs -u -k all
# reboot
# lsmod | grep -i vfio
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
Create a script file called `getgroups.sh`. Make it executable. Credit: [ArchWiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Ensuring_that_the_groups_are_valid)
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
# PERHAPS TRY DOING JUST THE VGA CONTROLLER HERE?
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
even if it does stop at that point the fb might still be taking memory - check the output of ?? (cat /proc/oimmumem) command


⚠️ Devices we don't want to pass CANNOT be in the same IOMMU group.

⛔ The screen goes blank, connection to host SSH and web interface are lost ⛔



❓Should I pass the PCIe bridges? NO
❓Should I pass the USB functions to vfio-pci ids? Not sure of the impact there.
📝 most people seem to only include the VGA controller and the HD audio controller
Perhaps some clarity on the Arch wiki:
- "Binding the audio device (10de:0fbb in above's example) is optional. Libvirt is able to unbind it from the snd_hda_intel driver on its own"
- That seems to imply for audio (PLUS the USB ones) that starting the VM will unbind from the host kernel and bind to VM
- "It is not necessary for all devices (or even expected device) from vfio.conf to be in dmesg output. Even if a device does not appear, it might still be visible and usable in the guest virtual machine."

❓ should i pass the iommu=pt parameter? Unclear. Arch wiki says yes, but then the discussion forum of that page says it's really only for older stuff.


https://forum.proxmox.com/threads/gpu-passthrough-windows-11-blinking-cursor.106782/
OP got things running like this:
```sh

GRUB_CMDLINE_LINUX_DEFAULT="quiet nomodeset video=vesafb:off video=efifb:off"
GRUB_CMDLINE_LINUX_DEFAULT="quiet ... video=efifb:off"
GRUB_CMDLINE_LINUX_DEFAULT="quiet video=efifb:off video=vesafb:off video=simplefb:off"
```
EFI Frame Buffer
https://passthroughpo.st/explaining-csm-efifboff-setting-boot-gpu-manually/
For GPU Passthrough, you do not want anything using the guest card. For this reason, you will need to add a kernel command-line parameter to disable the EFI/VESA framebuffer.

⚠️ No longer works after 5.15

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