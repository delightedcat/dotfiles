#!/bin/bash
#
# A simple script that installs dotfiles to the current system.
#
cp -r backgrounds/* /usr/share/backgrounds
cp -r icons/* /usr/share/icons
cp -r themes/* /usr/share/themes

cp avatar.png ~/.face
