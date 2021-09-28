#!/bin/bash
#
# A simple script that installs dotfiles to the current system.
#

# Copy over all backgrounds, icons and themes.
cp -r backgrounds/* /usr/share/backgrounds
cp -r icons/* /usr/share/icons
cp -r themes/* /usr/share/themes

# Copy the display manager profile image over.
cp .face ~/.face

# Put the Neovim configuration file in place.
mkdir -p ~/.config/nvim
cp -r nvim/* ~/.config/nvim
