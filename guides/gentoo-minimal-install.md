
# Gentoo Minimal Installation Notes

This set of notes adds on top of the standard [Gentoo installation guide for AMD64
](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation).
The original handbook should still be used to the installation. This document
covers some of my personal setup preferences.

## Optimal USE flags setup

The default USE flags are defined in `/etc/portage/make.conf`. Personally, I
like to set up my USE flags before emerging my `@world` set. It usually boils
down to something like this:
```
...
USE="-bluetooth -branding -cups -doc -gnome -kde -qt5 -systemd -upower -vala X minimal pulseaudio"
VIDEO_CARDS="nouveau" # Set this to match your own GPU vendor
ALSA_CARDS="hda-intel" # Set this to match your own sound card vendor
ACCEPT_KEYWORDS="~amd64" # Allows for "unstable" packages, leave this out if you prefer a more stable system
...
```

**NOTE:** Don't forget to set the `-march=native` flag as descibed in the
official guide. Next to these flags, the tool `cpuid2cpuflags` can be used to
determine the optimal CPU flags for your system. It can be used as follows:
```
emerge --ask app-portage/cpuid2cpuflags
cpuid2cpuflags
```

This command will return values that should be defined in your `CPU_FLAGS_X86`
flag. Alternatively, you might need `CPU_FLAGS_PPC` or `CPU_FLAGS_ARM`
depending on your CPU architecutre.

For more information, on CPU flags, check
[this article](https://wiki.gentoo.org/wiki/CPU_FLAGS_X86).

This can prevent a few dozen of packages from being compiled on your system and
will save you time in general. My USE flags are my personal preferences and can
and should be changed according to your own liking.

My flags are optimized for a minimal system without BlueTooth, CUPS and
Gnome/KDE support. My desktop environment of choice is Xfce.

## Minimal kernel configuration

Before updating my `@world` set during the initial setup, I first emerge
`sys-kernel/gentoo-sources` and assign a minimal configuration using
`make tinyconfig` in the kernel sources.

The reasoning behind emerging and setting a default configuration before
emerging the rest is that Portage will nicely list a summary of missing
kernel configuration options in `/var/log/portage/elog/summary.log` so that we
can use it to set up our kernel properly.

The commands used look something like this.
```
emerge --ask sys-kernel/gentoo-sources
eselect kernel set 1

# navigate to the selected kernel sources and go with a minimal default config
cd /usr/src/linux
make tinyconfig

# update the @world set
emerge --ask --verbose --update --newuse --deep @world
```

You can read the output log afterwards with:
```
less /var/log/portage/elog/summary.log
```

Once the initial `@world` set update is done and you are ready to configure the
kernel, you can get the Linux build process to generate a config for you based
on the loaded kernel modules. I recommend doing this *after* setting the
required options in the Gentoo installation handbook.
```
# From outside the chroot...
lsmod > /mnt/gentoo/MODULES

# Move back into the chroot before running the commands below
cd /usr/src/linux
make LSMOD=/MODULES localyesconfig
```

Note that we are using `localyesconfig` instead of `localmodconfig`. This will
set the kernel options to `Y` instead of `M` everywhere, which will eliminate
the need for an initramfs, unless you need some other firmware that is not
compiled into the kernel.

You'll most likely get some warnings and/or errors about which options should
be enabled. You can fix that by running `make menuconfig` and searching for
the configuration using `/`. Once done, you can compile your kernel as usual.

Since we are using a minimal configuration for the kernel now, there are some
settings missing. Ensure the following options are set accordingly:

- Make sure both `EMBEDDED` and `EXPERT` are set to `N`;
- You'll most likely need `PACKET` to be set to `Y` to allow IPv4 networking;
- Set `SECCOMP` to `Y`;
- Make sure `RTC_CLASS` is set to `Y` to allow the hardware clock to function
  properly;
- Ensure `NLS_CODEPAGE_437` and `NLS_ISO8859_1` are enabled, especially if you
  want your VFAT boot partition to mount;
- To make sure UTF-8 encoding is working well, enable `NLS_UTF8` as well;
- If you're using a graphical environment, you'll need `FB` to get framebuffers
  to work and `INPUT_EVDEV` to get keyboard and mouse input to work;
- Don't forget to select the right drivers for your graphics card (e.g.
  `DRM_NOUVEAU` when you have an Nvidia card).

Some additional options that you might want to add are:

- `CONFIG_POSIX_MQUEUE`
- `CONFIG_CGROUP_SCHED`
- `CONFIG_CGROUP_FREEZER`
- `CONFIG_CPUSETS`
- `CONFIG_CGROUP_CPUACCT`
- `CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE`
- `CONFIG_SUSPEND`
- `CONFIG_SUSPEND_FREEZER`
- `CONFIG_HIBERNATION`
- `CONFIG_ACPI_SLEEP`
- `CONFIG_COMPAT_32BIT_TIME`
- `CONFIG_USER_NS`

When all of this is done, simply compile and install the kernel as you 

## Use Git instead of rsync for Portage

Sure, rsync is an amazing and powerful tool. But why do this if you can use the
best VCS humanity has witnesses so far (not biased at all /s) to keep track of
your Portage ebuild, written by the same man behind Linux itself?

First off, make sure you have Git installed.
```
sudo emerge --ask dev-vcs/git
```
Then, open the Gentoo repository configuration file.
```
nano -w /etc/portage/repos.conf/gentoo.conf
```
Replace the contents of this file with the following:
```
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /var/db/repos/gentoo
sync-type = git
sync-uri = git://anongit.gentoo.org/repo/sync/gentoo.git
auto-sync = yes
```

Note that you can always copy the original configuration over from
`/usr/share/portage/config/repos.conf` in case something goes wrong or you wish
to revert to rsync.

To get everything to work, remove the packages direcory and pull everything in.
```
rm -rf /var/db/repos/gentoo
emerge --sync
```

The initial clone might take a while, so don't give up hope just yet!

## Use TMPFS for the Portage compile directory

When pulling in packages, they are of course being compiled from source. This
process happens in a specific directory on the system, namely
`/var/tmp/portage`. However, compiling something takes a lot of read and
write cycles on your precious SSD or HDD.

To avoid this, you can use a TMPFS on this directory to avoid many cycles.
The process is further explained in [this article from the Gentoo handbook
](https://wiki.gentoo.org/wiki/Portage_TMPDIR_on_tmpfs).

## Increase boot time

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

## Install and configure ccache
`ccache` is a handy application that prevents repeated compilcation of C and C++
objects. If you tend to change your `USE` flags a lot or don't want to worry
about recompiling a large program all over again upon failure, this might be for
you. A more extensive guide on how to set this up can be found on [this page of
the Gentoo handbook](https://wiki.gentoo.org/wiki/Ccache).

## Disable unused TTYs

By default, Gentoo will enable a total of 6 TTYs on your system. These are
defined in your `/etc/inittab` file. You'll most likely only need one or two
TTYs. Find the corresponding lines using `grep -n '/sbin/agetty' /etc/inittab`
and place a `#` in front of them using your text editor of choice to comment
them out.
