#!/bin/bash

# This script removes software from Linux Mint installations
# that are not required to operate the system. An exception
# to this is Timeshift, as Mint uses it to take backups.

# It also does not purge any packages that are used by Mint
# or the desktop environment itself (tested on Cinnamon).

# Usage:
# wget https://raw.githubusercontent.com/DelightedCat/dotfiles/main/scripts/purge-mint-bloat.sh
# chmod +x purge-mint-bloat.sh && ./purge-mint-bloat.sh
# rm -f purge-mint-bloat.sh

sudo apt purge \
    celluloid \
    gnote \
    hexchat-common \
    hexchat-perl \
    hexchat-plugins \
    hexchat-python3 \
    hexchat \
    hypnotix \
    libreoffice-common \
    onboard-common \
    pix \
    pix-data \
    redshift \
    rhythmbox \
    rhythmbox-data \
    seahorse \
    thunderbird \
    transmission-common \
    warpinator

sudo apt autoremove --purge
