#!/bin/bash

# Absolute paths to some core utilities
RM_BIN=/bin/rm
FIND_BIN=/usr/bin/find

# Absolute paths to the Portage binaries
EMERGE_BIN=/usr/bin/emerge
ESELECT_BIN=/usr/bin/eselect

MAKE_BIN=/usr/bin/make
GRUB_MKCONFIG_BIN=/usr/sbin/grub-mkconfig

VERBOSE=0
NO_SYNC=0

for ARG in "$@"; do
	if [[ $ARG == "--verbose" ]]; then
		VERBOSE=1
	elif [[ $ARG == "--no-sync" ]]; then
		NO_SYNC=1
	fi
done

# Update the Portage tree and clean up after ourselves
if [[ $NO_SYNC -ne 1 ]]; then $EMERGE_BIN --sync; fi
$EMERGE_BIN --update --changed-use --deep @world
$EMERGE_BIN --depclean

# Update the global symlink to the Linux sources
if [[ $VERBOSE -eq 1 ]]; then echo "Selecting first available kernel"; fi
$ESELECT_BIN kernel set 1

LINUX_SOURCES=$(realpath /usr/src/linux)
LINUX_BASENAME=$(basename $LINUX_SOURCES)

if [[ $VERBOSE -eq 1 ]]; then echo "Selected $LINUX_BASENAME"; fi

# Clean up old Linux sources in /usr/src
for SOURCES in $(ls -1 /usr/src); do
	BASENAME=$(basename $SOURCES)
	if [[ $BASENAME != $LINUX_BASENAME && $BASENAME != "linux" ]]; then
		$RM_BIN -rf $SOURCES
	fi
done

# Fetch the full name of the currently running kernel
LINUX_CURRENT=$(echo "linux-$(uname -r)")
if [[ $VERBOSE -eq 1 ]]; then echo "Currently running $LINUX_CURRENT"; fi

# Check if the running kernel does not equal the latest installed kernel.
# If this returns true, it means we'll need to update the kernel.
if [[ $LINUX_BASENAME != $LINUX_CURRENT ]]; then
	if [[ $VERBOSE -eq 1 ]]; then echo "Sources do not match running kernel"; fi
	if [[ $VERBOSE -eq 1 ]]; then echo "Preparing to install new kernel"; fi
	pushd /usr/src/linux
		$MAKE_BIN mrproper
		$MAKE_BIN clean
		$MAKE_BIN oldconfig
		$MAKE_BIN -j$(nproc) -l$(nproc) && make modules_install install
	popd

	# Determine the current relevent kernel versions.
	CURRENT_VERSION="$(uname -r)"
	SOURCES_VERSION="${LINUX_BASENAME:6}"

	# We're only keeping the current kernel and the newly installed one.
	$FIND_BIN /boot -maxdepth 1 -type f -name '*.old' -exec $RM_BIN -f {} +
	$FIND_BIN /boot -maxdepth 1 -type f -not -name "*$CURRENT_VERSION*" -not -name "*$SOURCES_VERSION*" -exec $RM_BIN -f {} +

	$GRUB_MKCONFIG_BIN -o /boot/grub/grub.cfg
fi

