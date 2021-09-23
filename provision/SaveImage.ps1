#TODO: Concatenate strings / use vars
#TODO: Check MD5 Sum to avoid downloading same thing more than once

#Invoke-WebRequest https://cloud-images.ubuntu.com/hirsute/current/hirsute-server-cloudimg-amd64-azure.vhd.zip -UseBasicParsing
#Invoke-WebRequest "https://cloud-images.ubuntu.com/hirsute/current/hirsute-server-cloudimg-amd64-azure.vhd.zip" -UseBasicParsing -OutFile "hirsute-server-cloudimg-amd64-azure.vhd.zip"
#Expand-Archive -LiteralPath "hirsute-server-cloudimg-amd64-azure.vhd.zip" -DestinationPath .

$Before = "C:\Users\vince\src\hyper-homelab\provision\livecd.ubuntu-cpc.azure.vhd"
$After = "C:\Users\vince\src\hyper-homelab\provision\livecd.ubuntu-cpc.azure.vhdx"
#Convert-VHD -Path livecd.ubuntu-cpc.azure.vhd –DestinationPath c:\livecd.ubuntu-cpc.azure.vhdx -WhatIf
Convert-VHD -Path $Before -DestinationPath $After #-WhatIf

"C:\Users\Public\Documents\Hyper-V\Virtual hard disk templates"


#Write-Host $Before$After

#TODO: Enable secure boot