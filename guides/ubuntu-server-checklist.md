# Ubuntu (22.04 LTS) Server Checklist

This is a small guide I mostly wrote for myself to use when I set up a new server.
My provider of choice is DigitalOcean. The installation process usually contains
the following steps:

- Update all system packages;
- Purge and hold `snapd` (snap is bloat);
- Install utilities (such as `net-tools`);
- Move SSH to a different port (for security reasons);
- Install and set up `endlessh` on port 22;
- Configure the firewall through `ufw`;
- Create a swapfile and configure it;

## Summary

Here's a rough summary of the commands needed to achieve the above.

### Update all system packages
```sh
apt update
apt dist-upgrade
reboot
```

### Purge and hold snapd
```sh
snap list
# delete all snaps in the list such as;
snap remove --purge lxd
snap remove --purge core20
snap remove --purge snapd

apt purge snapd
apt autoremove --purge
apt-mark hold snapd
rm -rf /root/snap
```

### Install utilities
```sh
apt install net-tools
```

### Move SSH to a different port
```diff
#/etc/ssh/sshd_config
-Port 22
+Port 1337
```

### Install and set up endlessh
```sh
apt install endlessh
```
Follow the instructions in `/var/lib/systemd/system/endlessh.service`.
Also create a config according to [the endlessh README](https://github.com/skeeto/endlessh).

### Configure the firewall through ufw
```sh
ufw default deny incoming
ufw default deny outgoing
ufw allow 22/tcp
ufw allow 1337/tcp
ufw enable
```

### Create a swapfile and configure it
```sh
dd if=/dev/zero of=/var/swap bs=1024 count=1048576
chmod 600 /var/swap
mkswap /var/swap
swapon /var/swap
```
Add the following rule to `/etc/fstab`:
```
/var/swap swap swap sw 0 0
```
Set up a proper production-level swappiness:
```sh
echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf
sysctl --system
sysctl vm.swappiness
```
