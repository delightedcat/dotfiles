
# Gentoo Linux Installation Notes

This document contains a brief summary of installation notes that I am using
during the installation of Gentoo GNU/Linux.

Please keep in mind that this guide should be used on top of the [official Gentoo handbook](https://wiki.gentoo.org/wiki/Handbook:Main_Page)
and is based on the [installation guide for AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation) and does not serve as a replacement.

## Optimal USE flags setup

Whereas the Gentoo installation guide will tell you to set the `USE` flags *after* you did your initial `@world` update,
I tend to set my `USE` flags *before*. Why? Because it saves time.

My `USE` flags on desktop installation usually look like this:
```
USE="X gtk pulseaudio -bluetooth -branding -cups -gnome -introspection -kde -qt5 -systemd -vala"
```
I usuallly add the following variables to ease up things a bit:
```
ACCEPT_LICENSE="*"
ACCEPT_KEYWORDS="~amd64"
```
The `~amd64` keyword will always pull in the "unstable" packages to have more of a "rolling release" feel to it.
I set Portage to accept all licenses, because I know which licenses the software that I'm using uses.

Besides, I'm also setting `USE_EXTENDED` variables such as `ALSA_CARDS`, `VIDEO_CARDS` and `CPU_FLAGS_X86`.
```
# For AMD cards
VIDEO_CARDS="amdgpu"
# For Nvidia cards (if you're using the open source drivers)
VIDEO_CARDS="nouveau"
```
The rest of the possible values can be found [here](https://wiki.gentoo.org/wiki/Category:Video_cards).
The `ALSA_CARDS` don't always have to be set. Only set this one if you're 100% sure what you've got the right card.

At last but not least there is `CPU_FLAGS_X86`. This one is a little more tricky to figure out, but luckily there's a tool
to determine the right flags for your CPU.
```
emerge --ask --oneshot cpuid2cpuflags
cpuid2gpuflags
```
This will output a string as such:
```
CPU_FLAGS_X86: aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3
```
This can be translated to the following variable in your `make.conf`:
```
CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3"
```

## Minimal kernel configuration

With the power of `make tinyconfig` and `make localyesconfig`, we are able to compile a minimal kernel
with only the options we need.

Once in chroot, I emerge the `sys-kernel/gentoo-sources` package *before* updating the `@world` set.
The reason for this is that it will output any missing kernel options to `/var/lib/portage/elog/summary.log`.

Even better, I configure as much as possible before I update the `@world` set to ensure that most basic options
are already set and will not show up in the logs.

The process usually looks like this:
```
lsmod > /mnt/gentoo/MODULES
chroot /mnt/gentoo /bin/bash
...
emerge --ask sys-kernel/gentoo-sources
eselect kernel set 1
cd /usr/src/linux
make tinyconfig
make menuconfig
...
make LSMOD=/MODULES localyesconfig
make && make modules_install install
```

Since we are compiling a minimal kernel, it is important to pay attention to the following options:

- Make sure `EMBEDDED` and `EXPERT` are both disabled (`EXPERT` has a dependency on `EMBEDDED`).
- Make sure `SECCOMP` is enabled; Gentoo uses it by default, even though it's not covered by the guide.
- Make sure `RTC_CLASS` is enabled, otherwise the hardware clock will not work.
- Make sure the right codepages/encodings are enabled; for most systems: `NLS_CODEPAGE_437`, `NLS_ISO8859_1` and `NLS_UTF8`.
- If you're using a graphical interface, you'll need to enable `INPUT_EVDEV` to get the keyboard and mouse to work.
- Ensure you have the right graphical drivers enabled, otherwise nothing will show up on your screen once you boot into your system.
	- It sometimes helps to enable a basic framebuffer and install the graphical drivers as a kernel module for easier debugging.
- If you want suspension/hibernation to work (you most likely will), enable the following options:
	- `SUSPEND`
	- `SUSPEND_FREEZER`
	- `SUSPEND_HIBERNATION`
	- `ACPI_SLEEP`
- Not all libraries will compile without compatibility for the 32-bit `time_t` type in C. These libraries will require `COMPAT_32BIT_TIME` to be enabled.
- Since disk space is pretty cheap these days and assuming your boot partition is large enough, let's prefer performance over disk space with `CC_OPTIMIZE_FOR_PERFORMANCE`.
- POSIX Message Queues are able to exchange data between processes to speed them up. Enable it with `POSIX_MQUEUE`.
- To enable isolation or limitation of resources usage of a collection of processes, make sure you enable the options that you need starting with `CGROUP`:
	- `CGROUP_SCHED`
	- `CGROUP_FREEZER`
	- `CGROUP_CPUACCT`
	- ...
- To enable cpusets (making them available at `/dev/cpusets`, enable to option: `CPUSETS`.

## Use Git instead of rsync for Portage

Sure, rsync is an amazing and powerful tool. But why use it if you can use the very VCS that was written by the same creator as our beloved kernel?
Instead of using rsync, it is possible to sync ebuild scripts using `emerge --sync` using Git.

First off, make sure you have Git installed.
```
emerge --ask dev-vcs/git
```
Then, place the following contents in `/etc/portage/repos.conf/gentoo.conf`:
```
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /var/db/repos/gentoo
sync-type = git
sync-uri = git://anongit.gentoo.org/repo/sync/gentoo.git
auto-sync = yes
```
Don't worry, you can always revert this change in case something goes wrong:
```
cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
```
To start using Git to sync packages, first remove the `gentoo` repository directory and
then sync the packages again.
```
rm -rf /var/db/repos/gentoo
emerge --sync
```
You'll notice Portage will pull in a Git repository at `/var/db/repos/gentoo` now.
The initial or even secondary clone might take a while, so don't give up hope just yet!

## Use tmpfs for the Portage compile directory

Packages are being downloaded and compiled in the `/var/tmp/portage` directory.
It is no secret though that compiling software demands a lot of read/write cycles on our precious SSD/HDD.

This is why it's a good idea to mount a tmpfs on `/var/tmp/portage`. Not only is it faster than using
a regular filesystem, it stores our packages' sources in memory rather than on disk, which saves us a
lot of write cycles on the long run.

**NOTE:** If you set the size of the tmpfs too high, it might start eating up your swap memory, which
means that the tmpfs is technically still reading/writing your hard disk.

First off, add the following line to `/etc/fstab`:
```
tmpfs		/var/tmp/portage	tmpfs		size=16G,uid=portage,gid=portage,mode=775,nosuid,noatime,nodev		0 0
```
Make sure to change the `size` option to tailor your needs. In my case, I have 16 GB of memory and 8 GB of swap space.

More information on this subject can be found in [this article from the Gentoo handbook](https://wiki.gentoo.org/wiki/Portage_TMPDIR_on_tmpfs).

## Speed up boot time

By default, OpenRC will start all services on the system one by one. This means
that if one task is being slow, it will stop the others from running until it
has completed. To fix this, set the following option in `/etc/rc.conf`:
```
rc_parallel="YES"
```

Another way to increase boot time is by installing `app-shells/dash` and settings
it as the default shell. It is said to be even more effective than making the system
boot up in parallel.
```
emerge --ask app-shells/dash
ln -sf /bin/dash /bin/sh
```

## Disable unused TTYs

A default Gentoo install comes with a bunch of TTYs enable by default. If you're running
Gentoo on the desktop however, you'll mostly want to enable these unused TTYs and stick with
only one.

TTYs are defined in `/etc/inittab` and can be disable by navigating to the right lines and
placing a `#` in front of it to comment it out. For example:
```
# TERMINALS
#x1:12345:respawn:/sbin/agetty 38400 console linux
c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux
#c2:2345:respawn:/sbin/agetty 38400 tty2 linux
#c3:2345:respawn:/sbin/agetty 38400 tty3 linux
#c4:2345:respawn:/sbin/agetty 38400 tty4 linux
#c5:2345:respawn:/sbin/agetty 38400 tty5 linux
#c6:2345:respawn:/sbin/agetty 38400 tty6 linux
```
As can be seen, I only have the first TTY enabled.

