# Network List and Description
**WAN**: These are public, static IP addresses.

**LAN**: The management netork. Bare-metal OS IPs, including Proxmox hosts.

**DMZ**: Virtualized infrastructure has IPs on this network.

# WAN
Purchased a block of 5 static IPs from AT&T. This network is configured by logging in to the AT&T router.
```
Network Address:        99.107.120.136
Usable Host IP Range:   99.107.120.137 - 99.107.120.142
Broadcast Address:      99.107.120.143
Total Number of Hosts:  8
Number of Usable Hosts: 6
Subnet Mask:            255.255.255.248
IP Class:               C
CIDR Notation:          /29
IP Type:                Public
Short:                  99.107.120.136 /29
```
# LAN
Router is a physical TPLink device.
```
Network:    192.168.128.0/24
Gateway:    192.168.128.1
DNS:        192.168.128.1
WAN IP:     99.107.120.139
```

# DMZ
Router is a container running firewalld.
```
Network:    192.168.129.0/24
Gateway:    192.168.129.1
DNS:        192.168.129.1
WAN IP:     99.107.120.140
```
