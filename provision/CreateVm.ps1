$VMName = "27"

 $VM = @{
     Name = $VMName
     MemoryStartupBytes = 2147483648
     Generation = 2
     Path = "C:\Virtual Machines\$VMName"
     SwitchName = "TheOutside"
     VHDPath = "27-os.vhdx"
     BootDevice = "VHD"
 }

 New-VM @VM
 Set-VMFirmware "27" -EnableSecureBoot "Off"
 Add-VMDvdDrive "27" -Path "27-seed.iso"