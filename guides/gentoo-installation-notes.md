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

### Custom Kernel

As you might have noticed, compiling a kernel through `sys-kernel/gentoo-kernel` or `genkernel` takes a very long time.
The reason for this is that both tools will compile with as many options enabled as possible.

The solution is compiling a custom kernel. Yes, it does sound scary, but the worst that can happen is that you'll need to
boot into your old kernel which is possible through GRUB's boot menu.

Compiling a kernel by hand is difficult in this day and age. Hardware is becoming exponentially more complicated.
Therefore it's my personal opinion that compiling a kernel by going through each option by hand is hard to do and probably not worth it, even using `lsmod` and `lspci` and all those tools.

My personal solution is basing the kernel off the previously installed kernel and enabling only what you need through `make localmodconfig`. The process looks mostly like this:
```
# sys-kernel/gentoo-sources is emerged with the symlink flag enabled
emerge --ask gentoo-sources
cd /usr/src/linux
# import the config of the current kernel
make oldconfig
# enable only the modules that are needed for this machine's hardware
make localmodconfig
make -j$(nproc)
make modules_install install
# install a tool that handles creating an initramfs for tools that are needed during early boot
emerge --ask dracut
dracut --hostonly
# update the bootloader's configuration
grub-mkconfig -o /boot/grub/grub.cfg
```

#### Handling Firmware Blobs

Note that it's recommend to not load redistributed firmware from `linux-firmware` in userspace.
The best solution to this problem is to embed the binary firmware blobs directly into the kernel.

```
# sys-kernel/linux-firmware is emerged with savedconfig enabled to modify which firmware is installed
emerge --ask linux-firmware
# write the currently loaded firmware blobs (only works right after a reboot)
dmesg | grep -i firmware | tee firmware.txt
```
You can now modify `/etc/portage/savedconfig/sys-kernel/linux-firmware<version>` to only contain the needed firmware according to `dmesg` and re-emerge `linux-firmware`.

Using this list of used firmware modules, you can embed the firmware blobs in the `EXTRA_FIRMWARE` option in the kernel configuration.
```
# copy-paste the output of this command and paste it in EXTRA_FIRMWARE in /usr/src/linux/.config
while read $(cat /etc/portage/savedconfig/sys-kernel/linux-firmware<version> | grep -v '^#') ; do echo -n $LINE ; done
```
