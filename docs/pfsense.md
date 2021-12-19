# Physical Setup
The computer has 3 ethernet ports:
1. onboard (re0)
1. pci card port #1 (igb0)
1. pci card port #2 (igb1)

We will ultimately want the management port to be the onboard port to be part of the LAN/management network that VMs do NOT have access to.

This will allow us to run the Raspberry Pi reboot via IPMI commands.

# Software Setup
- Avoid IPv6 DNS Servers (http://pfsense1.vnet seemed to default to ATT servers?!)
- Activate AES-NI Crypto
- Set DHCP Range to be Correct
- DHCP on MGMT Interface but not DMZ

## Restricting GUI Access in DMZ
https://docs.netgate.com/pfsense/en/latest/recipes/example-basic-configuration.html