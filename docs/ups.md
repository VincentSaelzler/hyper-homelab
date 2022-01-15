
# Debugging
```sh
upsdrvctl -t shutdown
# some output, then the commands that WOULD run
0.000077	Shutdown UPS: old-smart-1500
0.000082	exec:  /usr/local/libexec/nut/apcsmart -a old-smart-1500 -k
```
The UPS doesn't actually shut down when this is done. Probably doesn't pick up the config from `/usr/local/etc/nut/ups.conf`
```sh
# /usr/local/libexec/nut/apcsmart -a old-smart-1500 -k -DD
Network UPS Tools - APC Smart protocol driver 3.1 (2.7.4)
APC command table version 3.1
   0.000000	debug level is '2'
   0.000216	Initiating UPS shutdown
   0.043851	Communications with UPS lost: serial port read error: 1383(smartmode): Resource temporarily unavailable
   1.160389	Communications with UPS re-established
   1.160398	upsdrv_shutdown: setting SmartMode failed !
   1.218726	Communications with UPS lost: serial port read error: 1639(upsdrv_shutdown): Resource temporarily unavailable
   1.218731	upsdrv_shutdown: status read failed, assuming LB+OB
   1.218741	upsdrv_shutdown_simple: currently: on battery, sdtype: 5
   1.218747	sdcmd_AT: issuing [@] with 6 minutes of additional wakeup delay
   1.310514	Communications with UPS lost: serial port read error: 608(apc_write_long_i): Resource temporarily unavailable
   1.310519	issuing [@] with 3 digits failed
```
Clear extra config from `/usr/local/etc/nut/ups.conf`. The UPS still doesn't shut down, but the error message is slightly different.
```sh
# /usr/local/libexec/nut/apcsmart -a old-smart-1500 -k -DD
Network UPS Tools - APC Smart protocol driver 3.1 (2.7.4)
APC command table version 3.1
   0.000000	debug level is '2'
   0.000212	Initiating UPS shutdown
   0.112304	upsdrv_shutdown: status read failed, assuming LB+OB
   0.112312	upsdrv_shutdown_simple: currently: on battery, sdtype: 0
   0.112317	sdcmd_S: issuing [S]
   0.170649	sdok: got "NA"
   0.170653	sdok: last shutdown cmd failed

```
Explicitly pass awd arg as string. The UPS still doesn't shut down, same error message as without passing arg.
```sh
# /usr/local/libexec/nut/apcsmart -a old-smart-1500 -k -DD -x awd="001"
Network UPS Tools - APC Smart protocol driver 3.1 (2.7.4)
APC command table version 3.1
   0.000000	debug level is '2'
   0.000212	Initiating UPS shutdown
   0.112304	upsdrv_shutdown: status read failed, assuming LB+OB
   0.112312	upsdrv_shutdown_simple: currently: on battery, sdtype: 0
   0.112317	sdcmd_S: issuing [S]
   0.170649	sdok: got "NA"
   0.170653	sdok: last shutdown cmd failed
```
Explicitly pass awd arg as number. The UPS still doesn't shut down, no error message.
```sh
# /usr/local/libexec/nut/apcsmart -a old-smart-1500 -k -DD -x awd=001
Network UPS Tools - APC Smart protocol driver 3.1 (2.7.4)
APC command table version 3.1
   0.000000	debug level is '2'
   0.000217	Initiating UPS shutdown
   0.009487	Communications with UPS lost: serial port read error: 1383(smartmode): Resource temporarily unavailable
   1.067286	Communications with UPS re-established
   1.067293	upsdrv_shutdown: setting SmartMode failed !
   1.125632	Communications with UPS lost: serial port read error: 1639(upsdrv_shutdown): Resource temporarily unavailable
   1.125639	upsdrv_shutdown: status read failed, assuming LB+OB
   1.125644	upsdrv_shutdown_simple: currently: on battery, sdtype: 0
   1.125649	sdcmd_S: issuing [S]
```
Explicitly pass awd arg as number plus sdtype arg as number. Different messages now. This time, we have something that says "got SM" though. **UPS successfully does a hibernate!**
```sh
/usr/local/libexec/nut/apcsmart -a old-smart-1500 -k -DD -x awd=001 -x sdtype=1
Network UPS Tools - APC Smart protocol driver 3.1 (2.7.4)
APC command table version 3.1
   0.000000	debug level is '2'
   0.000216	Initiating UPS shutdown
   0.110206	upsdrv_shutdown: status read failed, assuming LB+OB
   0.110216	upsdrv_shutdown_simple: currently: on battery, sdtype: 1
   0.110221	sdcmd_S: issuing [S]
   0.168550	sdok: got "NA"
   0.168554	sdok: last shutdown cmd failed
   0.168557	sdcmd_AT: issuing [@] with 6 minutes of additional wakeup delay
   0.601821	sdok: got "SM"
   0.601831	sdok: last shutdown cmd failed
```

# Configuration Changes
## pfSense Changes:
Added lines to some files. Kept everything that was already there in place.
```sh
# /usr/local/etc/nut/upsd.conf
...
LISTEN 192.168.128.1
```
```sh
# /usr/local/etc/nut/upsd.users
...
[upsmon_remote]
password  = remote_pass
upsmon slave
```
```sh
# /usr/local/etc/nut/ups.conf
[old-smart-1500]
driver=apcsmart
port=/dev/cuau1
sdtype=5
awd=001
```

## Proxmox Changes
*Added* a line to this file:
```sh
# /etc/nut/upsmon.conf
...
MONITOR old-smart-1500@192.168.128.1 1 upsmon_remote remote_pass slave
```
*Replaced* a line in this file:
```sh
# /etc/nut/nut.conf
...
#MODE=none
MODE=netclient
```

# Testing Connectivity
http://abakalidis.blogspot.com/2013/04/using-raspberry-pi-as-ups-server-with.html

Seeing whether driver is connecting to UPS. Use pfSense web GUI.
- Status > System Logs > General
```
Jan 11 19:14:53 	upsd 	58838 	Can't connect to UPS [old-smart-1500] (apcsmart-old-smart-1500): No such file or directory
Jan 11 19:14:16 	upsmon 	35051 	Poll UPS [old-smart-1500] failed - Driver not connected 
```

Local test from pfSense.
```sh
/usr/local/bin/upsc old-smart-1500@localhost ups.status
ALARM OL RB # expected because the battery needs replacement
```
Remote test from Proxmox.
```sh
upsc old-smart-1500@192.168.128.1 ups.status
ALARM OL RB # expected because the battery needs replacement
```
Monitor the status of the process on Proxmox.
```sh
systemctl status nut-client
journalctl -u nut-monitor
```
# Default Configuration Files on pfSense
These are all default values, except the naming of the UPS
```sh
# ls /usr/local/etc/nut/
cmdvartab
driver.list
nut.conf
nut.conf.sample
ups.conf
ups.conf.sample
upsd.conf
upsd.conf.sample
upsd.users
upsd.users.sample
upsmon.conf
upsmon.conf.sample
upssched.conf
upssched.conf.sample
```
```sh
# /usr/local/etc/nut/nut.conf
...
MODE=none
```
```sh
# ls /usr/local/etc/nut/ups.conf
[old-smart-1500]
driver=usbhid-ups
port=auto
```
```sh
# /usr/local/etc/nut/upsd.conf
LISTEN 127.0.0.1
LISTEN ::1
```
```sh
# /usr/local/etc/nut/upsd.users
[admin]
password=5b87581eaaf6a1368e01
actions=set
instcmds=all
[local-monitor]
password=1326996b91c9e01c50d7
upsmon master
```
```sh
# /usr/local/etc/nut/upsmon.conf
MONITOR old-smart-1500 1 local-monitor 1326996b91c9e01c50d7 master
SHUTDOWNCMD "/sbin/shutdown -p +0"
POWERDOWNFLAG /etc/killpower
```
```sh
# /usr/local/etc/nut/upssched.conf
...
CMDSCRIPT /usr/local/bin/upssched-cmd
```
```sh
# /usr/local/bin/upssched-cmd
case $1 in
	upsgone)
		logger -t upssched-cmd "The UPS has been gone for awhile"
		;;
	*)
		logger -t upssched-cmd "Unrecognized command: $1"
		;;
esac
```
# Default Configuration Files on Proxmox
These are the defaults after installing the `nut` package using `apt`.
```sh
# ls -l /etc/nut/
-rw-r----- 1 root nut  1538 Oct 15  2020 nut.conf
-rw-r----- 1 root nut  5522 Oct 15  2020 ups.conf
-rw-r----- 1 root nut  4578 Oct 15  2020 upsd.conf
-rw-r----- 1 root nut  2131 Oct 15  2020 upsd.users
-rw-r----- 1 root nut 15308 Oct 15  2020 upsmon.conf
-rw-r----- 1 root nut  3879 Oct 15  2020 upssched.conf
```
```sh
# /etc/nut/nut.conf
...
MODE=none
```
```sh
# /etc/nut/ups.conf
...
maxretry = 3
```
```sh
# /etc/nut/upsd.conf
# all commented
```
```sh
# /etc/nut/upsd.users
# all commented
```
```sh
# /etc/nut/upsmon.conf
...
MINSUPPLIES 1
SHUTDOWNCMD "/sbin/shutdown -h +0"
POLLFREQ 5
POLLFREQALERT 5
HOSTSYNC 15
DEADTIME 15
POWERDOWNFLAG /etc/killpower
RBWARNTIME 43200
NOCOMMWARNTIME 300
FINALDELAY 5
```
```sh
# /etc/nut/upssched.conf
CMDSCRIPT /bin/upssched-cmd
```
```sh
# /bin/upssched-cmd
case $1 in
	upsgone)
		logger -t upssched-cmd "The UPS has been gone for awhile"
		;;
	*)
		logger -t upssched-cmd "Unrecognized command: $1"
		;;
esac
```
# References:
[Debugging Guide]([https://dan.langille.org/2020/09/10/nut-testing-the-shutdown-mechanism/)