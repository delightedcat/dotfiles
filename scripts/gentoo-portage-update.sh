#!/bin/bash

# Define some preset Portage binary paths
EMERGE_BIN=/usr/bin/emerge
ESELECT_BIN=/usr/bin/eselect

# Sync the latest packages, update and clean
$EMERGE_BIN --sync
$EMERGE_BIN --update --changed-use --deep @world
$EMERGE_BIN --depclean

# Since we cleaned any old kernels, we can assume that it is same to update
# the symlink to the kernel sources. This will be useful to check if we are
# running the latest available kernel version in other update scripts.
$ESELECT_BIN kernel set 1

