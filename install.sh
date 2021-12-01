#!/bin/bash
#
# Description: This script installs most contents from this repository.
# Author: DelightedCat <me@delightedcat.net>
#

# The absolute path to the cp binary file.
CP_BIN=/bin/cp

# Copy all global dotfiles to their global destinations.
${CP_BIN} -rv ./backgrounds/* /usr/share/backgrounds/
${CP_BIN} -rv ./xfce4/terminal/colorschemes/* /usr/share/xfce4/terminal/colorschemes/

# Copy all user dotfiles to their destinations.
${CP_BIN} -rv ./.face $HOME/
${CP_BIN} -rv ./gtk-3.0/* $HOME/.config/gtk-3.0/

