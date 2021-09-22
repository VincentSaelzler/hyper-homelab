#TODO: Concatenate strings / use vars
#TODO: Check MD5 Sum to avoid downloading same thing more than once

#Invoke-WebRequest https://cloud-images.ubuntu.com/hirsute/current/hirsute-server-cloudimg-amd64-azure.vhd.zip -UseBasicParsing
#Invoke-WebRequest "https://cloud-images.ubuntu.com/hirsute/current/hirsute-server-cloudimg-amd64-azure.vhd.zip" -UseBasicParsing -OutFile "hirsute-server-cloudimg-amd64-azure.vhd.zip"


#Expand-Archive -LiteralPath "hirsute-server-cloudimg-amd64-azure.vhd.zip" -DestinationPath .



#Convert-VHD –Path d:\VM01\Disk0.vhd –DestinationPath d:\VM01\Disk0.vhdx