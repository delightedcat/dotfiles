#!/bin/bash
#
# Description: This script installs most contents from this repository.
# Author: DelightedCat <me@delightedcat.net>
#

# The absolute path to the git and cp binaries.
GIT_BIN=/usr/bin/git
CP_BIN=/bin/cp

# Ensure we got the latest submodules pulled in.
${GIT_BIN} submodule update --init --recursive

# Copy all global dotfiles to their global destinations.
${CP_BIN} -rv ./backgrounds/* /usr/share/backgrounds/
${CP_BIN} -rv ./themes/* /usr/share/themes/
${CP_BIN} -rv ./icons/* /usr/share/icons/
${CP_BIN} -rv ./xfce4/terminal/colorschemes/* /usr/share/xfce4/terminal/colorschemes/

# Copy all user dotfiles to their destinations.
${CP_BIN} -rv ./.face $HOME/
${CP_BIN} -rv ./gtk-3.0/* $HOME/.config/gtk-3.0/

