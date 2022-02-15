# Creating a swapfile using the Btrfs filesystem

Since kernel version 5.0, it is possible to create a swapfile when you're using the Btrfs filesystem on your system.
It does take a few steps to get there, though.

First, you need to prepare a non-snapshotted subvolume to host the file. Then, the `No_COW` attribute must be set with `chattr`. Lastly, compression should be disabled on the subvolume.
```sh
truncate -s 0 /swapfile
chattr +C /swapfile
btrfs property set /swapfile compression none
```
You can now create a swapfile as you normally would.
```sh
dd if=/dev/zero of=/swapfile bs=1024 count=4194304 status=progress
```
The command above will allocate a swapfile of 4 GiB. The forumla for the final allocate space is `bs * count` where both inputs are the desired size in bytes, e.g. `1024 * 4194304 = 4294967296 = 4 GiB`.
```sh
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```
If all goes well and you get no error output, your swapfile should be active.
You can test this using `swapon -a` or a tool such as `htop`.

Now, to finish it all up, add the swapfile to `/etc/fstab` to ensure it gets mounted automatically once you reboot.
```sh
# Add this line to /etc/fstab
/swapfile	none	swap	sw	0 0
```
Each section of the line should be separated using a single tab or space. No more, no less.
