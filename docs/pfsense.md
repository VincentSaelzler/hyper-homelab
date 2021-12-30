# Physical Setup
The computer has 3 ethernet ports:
1. onboard (re0) = MGMT (aka LAN)
1. pci card port #1 (igb0) = WAN
1. pci card port #2 (igb1) = DMZ

# Manual Bootstraping
## Command-Line Interface
This needs to be done on the physical computer running pfSense.
- Assign interfaces
- Set LAN interface IP
- Set LAN interface DHCP range

## Web GUI
Install packages:
- `nut`
- `syslog-ng`

## Everything Else
Everything beyond that can be restored from the backup file.

# Configuration Backup and Restoration
Use the AutoConfigBackup service. This is totally free, and provides offsite backups from Netgate. Instructions from Netgate website are easy and clear.

# Software Setup
> ⚠️ WARNING: Changes made by Ansible are wiped out when configuration is changed via the GUI
- Avoid IPv6 DNS Servers (http://pfsense1.vnet seemed to default to ATT servers?!)
- Activate AES-NI Crypto
- Set DHCP Range to be Correct
- DHCP on MGMT Interface but not DMZ
- root PW and authorized keys

## Packages
The backup config file does **not** automatically re-install packages when restored. It **does** save the configuration values from before.
### NUT
Mostly defaults, but need to name the ups `old-smart-1500`.

> ✅ TIP: Click the ADVANCED button to make changes to `upsd.conf` and `upsd.users`.
### Syslog-ng
Mostly defaults. Set retention period to 30 days and don't compress logs.

## Restricting GUI Access in DMZ
https://docs.netgate.com/pfsense/en/latest/recipes/example-basic-configuration.html