$VMName = "27"
$SwitchName = "TheOutside"

$VM = @{
     Name = "$VMName"
     Generation = 2
     SwitchName = $SwitchName
     VHDPath = "$VMName-os.vhdx"
 }

New-VM @VM
Set-VMFirmware "$VMName" -EnableSecureBoot Off
Add-VMDvdDrive "$VMName" -Path "$VMName-seed.iso"

#can't seem to make this work but it might not matter
#check if the router forwards via IP before wasting more time.
#Set-VMNetworkAdapter -VMName "27" -StaticMacAddress "85B3FD973932"