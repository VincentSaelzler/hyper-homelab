Configuration files are saved in `usr/local/etc/nut`

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