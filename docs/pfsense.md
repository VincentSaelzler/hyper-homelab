# Physical Setup
The computer has 3 ethernet ports:
1. onboard (re0)
1. pci card port #1 (igb0)
1. pci card port #2 (igb1)

We will ultimately want the management port to be the onboard port to be part of the LAN/management network that VMs do NOT have access to.

This will allow us to run the Raspberry Pi reboot via IPMI commands.

# Software Setup
> ⚠️ WARNING: Changes made by Ansible are wiped out when configuration is changed via the GUI
- Avoid IPv6 DNS Servers (http://pfsense1.vnet seemed to default to ATT servers?!)
- Activate AES-NI Crypto
- Set DHCP Range to be Correct
- DHCP on MGMT Interface but not DMZ

# Packages
The backup config file does **not** automatically re-install packages when restored. It **does** save the configuration values from before.
# NUT
Mostly defaults, but need to name the ups `old-smart-1500`.

> ✅ TIP: Click the ADVANCED button to make changes to `upsd.conf` and `upsd.users`.
# Syslog
Mostly defaults. Set retention period to 30 days and don't compress logs.

## Restricting GUI Access in DMZ
https://docs.netgate.com/pfsense/en/latest/recipes/example-basic-configuration.html