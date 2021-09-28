$VMName = "27"
$SwitchName = "TheOutside"
$VHDSize = 8589934592 # that's 8 GiB
$VHDFile = "$VMName-os.vhdx"

$VM = @{
     Name = "$VMName"
     Generation = 2
     SwitchName = $SwitchName
     VHDPath = $VHDFile
}

Resize-VHD -Path $VHDFile -SizeBytes $VHDSize

New-VM @VM
Set-VMFirmware "$VMName" -EnableSecureBoot Off
Add-VMDvdDrive "$VMName" -Path "$VMName-seed.iso"
Set-VM "$VMName" -EnhancedSessionTransportType HvSocket

Start-VM $VMName

#can't seem to make this work but it might not matter
#check if the router forwards via IP before wasting more time.
#Set-VMNetworkAdapter -VMName "27" -StaticMacAddress "85B3FD973932"