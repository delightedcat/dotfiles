
# Ubuntu Server Install Cheatsheet

A quick overview of on how to install a server using Ubuntu 20.04 LTS.

## Updating
First, install all updates.
```
apt update
apt dist-upgrade
```

### Uninstall snapd
Uninstall `snapd` if needed:
```
snap list
```
Remove all packages in this list.
```
snap remove --purge <package-name>
```
Once all packages are cleared, it's safe to delete `snapd` itself.
```
apt purge snapd
apt autoremove --purge
```
Remove the user preferences and cache directories.
```
rm -rf /var/cache/snapd
rm -rf ~/snap
```

## Setup user and login management
Create a new secondary non-root user with `sudo` permissions.
```
useradd -m -G sudo -s /bin/bash <user>
passwd <user>
```

Disable remote logins from the root user by editing the config:
```
nano /etc/ssh/sshd_config
```
Then, edit `PermitRootLogin` to be `no`. Restart the SSH daemon:
```
systemctl restart sshd
```

### Generate and set SSH key
On your client system, generate a new SSH key (4096-bit RSA in ths case):
```
ssh-keygen -t rsa -b 4096 -C <user>@<hostname>
```
Replace `<user>` and `<hostname>` to match your client system.

Now, copy the key over to the server. This can be done in various ways.
Personally I use the following method. On the server:
```
sudo -i -u <user>
mkdir ~/.ssh
chmod 700 ~/.ssh
echo "<your public key here>" > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```
Don't forget to replace `<your public key here>` with your newly generated
public key on the client system.

Once you confirmed you can log in using SSH (with the `-i` option, see `man ssh`),
you can disable plain text password logins by editing the config:
```
nano /etc/ssh/sshd_config
```
Now, uncomment `PasswordAuthentication` and set it to `no`. Restart SSH once again:
```
systemctl restart sshd
```

## Configure the firewall
Configure and enable `ufw` to ensure there is a firewall.
```
ufw allow 22/tcp
ufw enable
```
For added security, you can install `endlessh`:
```
apt install endlessh
```
You should then follow the instructions from [the endlessh repository](https://github.com/skeeto/endlessh).
Don't forget to edit `/etc/ssh/sshd_config` to not use port 22 (defined by the `Port` option).

## Hardening

It's recommended to disable unused services, some example include:

- `abrt-xorg`
- `abrtd`
- `rpcbind`
- `xinetd`

In the case of a PHP install, especially as a shared hosting provider, it is desireable that the following option is set in `php.ini`:
```
disable_functions = show_source, system, shell_exec, passthru, exec, popen, proc_open
```
