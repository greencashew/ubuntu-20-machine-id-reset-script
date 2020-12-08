# Ubuntu 20.+ - Machine id reset script

## Purpose

### Description

In case of cloning **Ubuntu** OS with version 20.+ we can notice that DHCP treat all virtual machines as one. Possible
reason could be that **machine id** for all OS copies is the same.

To check **machine-id** use command:

```bash
cat /etc/machine-id
```

### Conditions

- Virtualization (Virtualbox, Vmware)
- Cloned Ubuntu Virtual Machines have assigned **same IP address** by DHCP.
- Machine-Id doesn't change

## Solution

### Script

1. Enter **Ubuntu VM** to be cloned
1. Download script `reset-machine-id.sh`
1. Run `sudo ./reset-machine-id.sh install`
1. Clone your prime virtual machine
1. Start your virtual machines
1. Machine id-s for each VM should be different.

#### Usage in details

```bash
 sudo ./reset-machine-id.sh                 Reset machine id and create already run indicator under path $RESET_FILE_PATH

 sudo ./reset-machine-id.sh install         Install service which run reset-machine-id.sh on every system startup if indicator file $RESET_FILE_PATH doesn't exists.
 sudo ./reset-machine-id.sh prepare         Remove indicator file so reset id script file can run during next startup.
 sudo ./reset-machine-id.sh uninstall       Uninstall script
 sudo ./reset-machine-id.sh help            Open this help
```

### Manual solution

You can also run below commands manually on each machine:

```bash
sudo rm -f /etc/machine-id
sudo dbus-uuidgen --ensure=/etc/machine-id
sudo rm /var/lib/dbus/machine-id
sudo dbus-uuidgen --ensure
sudo dhclient -r
```
