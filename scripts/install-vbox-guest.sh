#!/bin/bash

# create a mount point and mount the inserted CD
sudo mkdir -p /mnt/cdrom
sudo mount /dev/cdrom /mnt/cdrom

# run the guest additions installation script
sudo bash /mnt/cdrom/VBoxLinuxAdditions.run

# unmount the installation CD and remove the mount directory
sudo umount -l /mnt/cdrom
sudo rm -rf /mnt/cdrom
