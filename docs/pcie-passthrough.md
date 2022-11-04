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