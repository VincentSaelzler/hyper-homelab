# Network List and Description
**Public**: These are public, static IP addresses.

**ATT**: These are the "private" addresses coming from the AT&T router. Only real use is to connect to the router to change configuratoin settings.

**LAN**: The main "LAN" segment. Includes bare-metal OS IPs, Wi-Fi AP, and iDRAC addresses.

**DMZ**: Virtualized infrastructure has IPs on this network.

# Public
Purchased a block of 5 static IPs from AT&T. This network is configured by logging in to the AT&T router, using the ATT network.
```
Gateway: 99.107.120.142
Subnet: 255.255.255.248
First Usable: 99.107.120.137
Lat Usable: 99.107.120.141
```
WAN port of pfSense is `99.107.120.137`

# ATT
```
Network: 192.168.1.0/24
Gateway: 192.168.1.254
```
Router config is at `192.168.1.254`

# LAN
```
Network: 192.168.128.0/24
Gateway: 192.168.128.1
DNS: 192.168.128.1
```
The LAN side of the pfSense router is at `192.168.128.1`

This is the main subnet, so hosts of certain types use different addresses.
- `02` - `29`: Hypervisor Web GUI
- `30` - `49`: Hardware (APs, iDRAC ports, Switch Admin Web GUI)
- `50` - `59`: Other Bare-Metal OS Addresses
- `60` - `69`: Clients with Static DHCP Reservations (e.g. to consistenly enable remote access)
- `70` - `99`: Dynamic DHCP range.

## Hosts on LAN

|Address|Host|Description|
|---|---|---|
|1|pfsense1|pfSense Router|
|2|pve2|Proxmox Node|
|3|pve3|Proxmox Node|
|4|pve4|Proxmox Node|
|5|pve5|Proxmox Node|
|30|(none)|TP-Link EAP 115 Access Point|
|31|(none)|Dell PowerConnect 2824 Switch|
|32|(none)|Dell PowerEdge R620 iDRAC|
|33|(none)|Dell PowerEdge R720xd iDRAC|
|50|pbu0|Proxmox Backup Server|
|60|devenv|Dev Environment and Ansible Host for VMs|

# DMZ
```
Network: 192.168.129.0/24
Gateway: 192.168.129.1
DNS: 192.168.129.1
```
The LAN side of the pfSense router is at `192.168.129.1` (_it's the same pfSense as for the LAN network_)
