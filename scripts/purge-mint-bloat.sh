#!/bin/bash

sudo apt purge \
    celluloid \
    gnote \
    hexchat-common \
    hexchat-perl \
    hexchat-plugins \
    hexchat-python3 \
    hexchat \
    hypnotix \
    libreoffice-help-common \
    onboard-common \
    onboard \
    pix-data \
    pix-dbg \
    pix \
    redshift-gtk \
    redshift \
    rhythmbox \
    rhythmbox-data \
    rhythmbox-plugin-tray-icon \
    rhythmbox-plugins \
    thunderbird \
    transmission-common \
    transmission-gtk \
    warpinator

sudo apt autoremove --purge
