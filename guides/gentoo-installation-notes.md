# Gentoo GNU/Linux Installation Notes

This guide is intended to substitute the [Gentoo Linux amd64 Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation).
It should **not** be used as a replacement. It should rather be used as a way to extend the existing guide with additional tips and tricks.

### General Summary

A classic Gentoo GNU/Linux (referred to as "Gentoo" from now on) on my end usually consists of the following steps.
Please note that these steps differ from user to user and you should always tailor the steps to your own needs:

- Setup a network connection (usually automatic through ethernet);
- Partition the disk (~256M for `/boot` and the rest for `/`);
- Create filesystems on partitions (VFAT for `/boot` and ext4 for `/`);
- Mount root filesystem on `/mnt/gentoo`;
- Download and install the stage3 tarball;
- Setup compile options in `/etc/portage/make.conf` (i.e. `MAKEOPTS` and `EMERGE_DEFAULT_OPTS`);
- Mount `/proc`, `/dev`, `/sys` and `/run` on the chroot (`/mnt/gentoo`);
- Copy the `repos.conf` file and `/etc/resolv.conf` to the chroot;
- Chroot into the mounted root directory (`chroot /mnt/gentoo /bin/bash` and `source /etc/profile` and `export PS1="(chroot) ${PS1}"`);
- Mount the boot partition on `/boot`;
- Pull in the latest package tree (`emerge-webrsync` and `emerge --sync`);
- Clean up `eselect news` (`eselect news read` and `eselect news purge`);
- Set the corresponding profile (`eselect profile list` and `eselect profile set <number>`);
- Set up the corresponding `USE` and license/keyword flags in `/etc/portage/make.conf`;
- Set up `CPU_FLAGS_X86` using `cpuid2cpuflags` (`emerge --oneshot cpuid2cpuflags`);
- Run `@world` update (`emerge --ask --verbose --update --newuse --deep @world`);
- Set up timezone and locale (`/etc/timezone` and `/etc/locale.gen` with `eselect locale list` and `eselect locale set <number>`);
- Install `sys-kernel/gentoo-kernel` (we'll replace this with a custom kernel once the system boots);
- Set up `/etc/fstab` using the `blkid` command;
- Set up networking information (`/etc/init.d/hostname` and `/etc/init.d/net`; options: `dns_domain_lo` and `config_<interface>`);
- Set up loopback device symlink to enable networking on boot (`cd /etc/init.d` and `ln -s net.lo net.<interface>` and `rc-update add net.<interface> default`);
- Install DHCP client (`emerge --ask dhcpcd` and `rc-update add dhcpcd default`);
- Set up `/etc/hosts` (Add `/etc/init.d/hostname` hostname value for `127.0.0.1`);
- Set up root password (Might want to re-emerge `sys-auth/pambase` without `passwdqc` to avoid weird password requirements);
- Set `/etc/conf.d/hwclock` to `local` instead of `UTC` if system time isn't UTC;
- Install and enable system logger (e.g. `emerge --ask metalog` and `rc-update add metalog default`);
- Install and enable cron daemon (e.g. `emerge --ask fcron` and `rc-update add fcron default`);
- Install file locator (`emerge --ask mlocate`);
- Install and enable time synchorization (`emerge --ask chrony` and `rc-update add chronyd default`);
- Install required filesystem tools (e.g. `emerge --ask e2fsprogs dosfstools`);
- Set up and install bootloader (e.g. `echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf` and `emerge --ask grub`);
- Install bootloader on `/boot` (e.g. `grub-install --target=x86_64-efi --efi-directory=/boot --removable` and `grub-mkconfig -o /boot/grub/grub.cfg`);
- Reboot the system and verify everything is working;

