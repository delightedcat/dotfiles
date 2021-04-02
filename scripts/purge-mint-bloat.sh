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
