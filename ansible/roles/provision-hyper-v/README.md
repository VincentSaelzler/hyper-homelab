# Required Variables
There are some variables that are *assumed* to be in scope when running this role.

Individual Host Variables (the virtual machine being created)
```
id
iface_name
ansible_host (IP)
inventory_hostname
```

Variables Related to the Hyper-V Server (passed in `srv_det` variable)
```
vhd_dir
vhd_dir_windows
switch_name
```

Variables related to the networking environment
```sh
# current values (only have a single internal network)
network: "192.168.1.0"
netmask: "255.255.255.0"
broadcast: "192.168.1.255"
gateway: "192.168.1.254"
```

Credentials
```
root_pw
lin_pub_key
win_pub_key
```