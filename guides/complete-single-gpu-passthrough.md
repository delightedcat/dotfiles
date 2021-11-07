

## Complete Single GPU Passthrough Guide

As the title suggests, this is a complete guide on setting up GPU passthrough to a Windows virtual machine with only a single GPU. So, why would you want to do this?

Imagine you are running Linux on your computer and you want to play video games that are only available on Windows. You do not want to dual boot, so the next logical option would be running a VM from your Linux machine. A VM turns out to be too slow to play any video games at a proper rate, due to the simple fact that a VM does not have a GPU to its availability.

A solution to this problem would be to pass your GPU through to your VM, but a GPU can only be used by one OS at a time. So what to do, without buying another GPU just for the sake of playing video games from a VM? The solution can be found in this guide.

We'll be passing through the GPU to the virtual machine using libvirt hooks. This means that scripts will be automatically executed upon starting and stopping our VM. These scripts will take care of unbinding and binding the GPU from our main OS.

This guide should work on most Linux distributions. In this guide, the following things are assumed:

- You are running a Ubuntu-based distribution (Linux Mint 20.1 Cinnamon in my case);
- You are using systemd as your init system;
- You use GRUB as your boot loader.

Keep in mind that the above list are no requirements. You'll most likely be able to get it working on your distribution, except with different commands that are specific to your init system, package manager and boot loader. The example hook scripts will have lines for AMD and the OpenRC init system as well.

#### Enabling and verifying virtualization

First off, you need to confirm that virtualization is actually possible on your CPU. This option is usually called VT-d on Intel processors and AMD-v on AMD processors. This guide will not go over how to enable virtualization in your BIOS, as it can be found in different places and has a slightly different name across different manufacturers.

Once you have ensured that virtualization is enabled in BIOS, edit the GRUB configuration file.
```sh
sudo nano /etc/default/grub
```
Make the following changes to the option `GRUB_CMDLINE_LINUX_DEFAULT`.
```sh
GRUB_CMDLINE_LINUX_DEFAULT="... intel_iommu=on" # If you're using an Intel CPU
GRUB_CMDLINE_LINUX_DEFAULT="... amd_iommu=on" # If you're using an AMD CPU
```
Quit and save using `Ctrl + X` and `Y`. Now let's update GRUB with our changes and reboot to make our changes take effect.
```
sudo update-grub && reboot
```
Once booted, run the following command to check if IOMMU is enabled.
```
dmesg | grep 'IOMMU enabled'
```
If you're receiving output, it worked! If it didn't work, your CPU might not support virtualization or it's not enabled correctly in BIOS. There's one more thing left to check now. We need to confirm that your IOMMU groups are sane and valid.

Have a look at the following script taken from the [Arch Wiki](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF):
```sh
#!/bin/bash
shopt -s nullglob
for g in `find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V`; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```
Place it in a file called `iommu-groups.sh` and run:
```
chmod +x iommu-groups.sh
./iommu-groups.sh
```
Look out for your GPU and make sure it's grouped properly and would not conflict with other hardware.
The reason for this is that, when passing through hardware, all other hardware in the same IOMMU group needs to have been passed through as well.

If you come to the conclusion that your devices are not properly grouped, you might consider [applying the ACS patch](https://queuecumber.gitlab.io/linux-acs-override/) to your kernel.
This does come with some security risks though, as there's a chance your VM will start writing to your host OS's memory.

#### Installing and preparing our tools

The following packages are required to create our virtual machine.

- `qemu-kvm`
- `qemu-utils`
- `libvirt-daemon`
- `bridge-utils`
- `virt-manager`
- `ovmf`

These can easily be installed as such if your package manager is APT.
```
sudo apt install qemu-kvm \
    qemu-utils \
    libvirt-daemon \
    bridge-utils \
    virt-manager \
    ovmf
```
Once the installation is done, enable and start the `libvirtd` and `virtlogd` services.
```
systemctl enable --now libvirtd
systemctl enable --now virtlogd
```
Also make sure that the networking features are running properly.
```
virsh net-start default
virsh net-autostart default
```
At last but not least, add your current user to the `input`, `kvm` and `libvirt` groups.
```
sudo usermod -aG input,kvm,libvirt $USER
```
There groups are required in order to gain access to libvirt and any input devices we'll be passing through. A logout might be required before the newly assigned groups will take effect. You can check this using the `groups` command.

#### Installing the guest OS

Let's get started with installing the guest OS itself. First of all, you need to download a Windows ISO and VirtIO driver ISO. Then, open virt-manager through your desktop environment or type the following in the terminal.
```
virt-manager &
```
This will start virt-manager in the background. A GUI should now pop up from which we'll create our VM and install the guest OS on it.

Go ahead and create a new virtual machine as you normally would. Before finishing, make sure you check the "Customize configuration before install". Now, take care of the following settings.

- Overview
    - Chipset -> Q35
    - Firmware -> UEFI x64_86 (/usr/share/OVMF/OVMF_CODE.fd)
- CPUs
    - Uncheck "Copy host CPU configuration"
    - Model -> host-passthrough
- SATA Disk 1
    - Uncollapse "Advanced options"
    - Disk bus -> VirtIO
- NIC
    - Device model -> virtio

Next, we need to add the VirtIO ISO to the VM before finishing up the configuration using the "Add Hardware" option.

- Device type -> CDROM device
- Select VirtIO driver ISO using "Manage..."

To start installing Windows, click "Begin installation". Install the operating system as you normally would, until you reach the disk selection. You'll notice that there are no disks available to choose from. This is because Windows does not recognize VirtIO disks by default. To fix this, follow the steps below.

- Click "Load driver" and then "Browse..."
- Select de E: drive and navigate to E:\amd64\w10
- Press "OK" and then "Next"

Choose the disk you wish to install Windows to and continue the installation as you normally would.

Once booted into Windows, right-click the Windows logo and choose "Device Manager". From here, we'll install the correct VirtIO drivers to our devices. Let's get started with the "Ethernet Controller" device. Right-click it and choose "Update driver". From there, follow the steps below.

- Choose "Browse my computer for drivers"
- "Browse..."
- This PC -> CD Drive (E:)

Repeat the steps described above for all unknown devices and "Microsoft Basic Display Manager". Once done, you have successfully installed the guest OS itself. Shut down the VM and move to **View -> Details**. Let's get rid of the following hardware:

- SATA CDROM 1
- SATA CDROM 2
- Tablet
- Display Spice
- Sound ich*
- Channel spice
- Video QXL
- Any USB Redirector devices

Now, enable XML editing by returning to the main virt-manager Windows and enable **Edit -> Preferences -> Enable XML editing**. You can now edit the XML configuration of your VM by opening the corresponding window and go to **View -> Details -> Overview -> XML**. Make the following addition.
```xml
...
<features>
  ...
  <hyperv>
    ...
    <vendor_id state='on' value='whatever'/>
    ...
  </hyperv>
  ...
  <kvm>
    <hidden state='on'/>
  </kvm>
  ...
</features>
...
```

This will hide the fact that we are running a VM for the guest OS, seeing as graphics drivers don't like running in a VM and will most likely not do anything at all.

### Setting up libvirt hooks

These hooks will take care of unbinding the GPU from our main OS in order to make it available to our guest OS. The installation described here is based on [https://passthroughpo.st/simple-per-vm-libvirt-hooks-with-the-vfio-tools-hook-helper/](this article).
```sh
sudo mkdir -p /etc/libvirt/hooks

sudo wget 'https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu' -O /etc/libvirt/hooks/qemu
sudo chmod +x /etc/libvirt/hooks/qemu

sudo service libvirtd restart
```
Since we restarted the libvirtd service, you might need to restart virt-manager as well.

Let's initialize the hook scripts. Please note that you need to replace `<domain>` with the configured name of your VM.
```sh
# Create start script
sudo mkdir -p /etc/libvirt/hooks/qemu.d/<domain>/prepare/begin
sudo touch /etc/libvirt/hooks/qemu.d/<domain>/prepare/begin/start.sh
sudo chmod +x /etc/libvirt/hooks/qemu.d/<domain>/prepare/begin/start.sh

# Create stop script
sudo mkdir -p /etc/libvirt/hooks/qemu.d/<domain>/release/end
sudo touch /etc/libvirt/hooks/qemu.d/<domain>/release/end/stop.sh
sudo chmod +x /etc/libvirt/hooks/qemu.d/<domain>/release/end/stop.sh
```
Now it's time create the actual scripts that we'll use to unbind and rebind your GPU from your main OS. Since the script mostly depends on which hardware you're using, it's not possible to have one script that works for everything. That's why I'll share my scripts here with a few notes. First off, here's my `start.sh` with additional comments.
```sh
#!/bin/bash
set -x

# Stop display manager if you're using systemd
systemctl stop display-manager
# Use this instead if OpenRC is your init system
# rc-service xdm stop

# Unbind VTconsoles
# You can check how many you have and need to unbind using `ls -1 /sys/class/vtconsole`
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# Unbind EFI Framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Unload NVIDIA kernel modules if you're using NVIDIA
modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia
# Unload AMD kernel module if you're using AMD
# modprobe -r amdgpu

# Detach GPU devices from host
# Make sure all devices in the same IOMMU group as your GPU
# are detached and the GPU itself
virsh nodedev-detach pci_0000_01_00_0
virsh nodedev-detach pci_0000_01_00_1
virsh nodedev-detach pci_0000_01_00_2
virsh nodedev-detach pci_0000_01_00_3

# Load vfio module
modprobe vfio-pci
```
Below you will find my `stop.sh` script.
```sh
#!/bin/bash
set -x

# Unload vfio module
modprobe -r vfio-pci

# Attach GPU devices to host
# These are the same devices that were detached in start.sh
virsh nodedev-reattach pci_0000_01_00_0
virsh nodedev-reattach pci_0000_01_00_1
virsh nodedev-reattach pci_0000_01_00_2
virsh nodedev-reattach pci_0000_01_00_3

# Rebind VT consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo 1 > /sys/class/vtconsole/vtcon1/bind

# Rebind framebuffer to host
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

# Load NVIDIA kernel modules if you're using NVIDIA
modprobe nvidia_drm
modprobe nvidia_modeset
modprobe nvidia_uvm
modprobe nvidia
# Load AMD kernel module if you're using AMD
# modprobe amdgpu

# Restart Display Manager if you're using systemd
systemctl start display-manager
# Use this instead of OpenRC is your init system
# rc-service xdm start
```
You can edit the scripts we previously created using the following commands.
```sh
sudo nano /etc/libvirt/hooks/qemu.d/<domain>/prepare/begin/start.sh
sudo nano /etc/libvirt/hooks/qemu.d/<domain>/release/end/stop.sh
```

#### Passing through the GPU and USB devices

The final step in the process is configuring which PCI and USB devices we'll pass through to the VM. Open the VM through virt-manager and go to **View -> Details**. From there, go to **Add Hardware -> PCI Host Device** and add the same devices as we've previously detached in the `start.sh` hook script. Repease the process until you added all PCI devices you want to pass through. In our case, this is GPU and all other devices in the same IOMMU group.

You'll most likely also want to pass through some USB devices such as your mouse and keyboard. This can be done using **Add Hardware -> USB Host Device**. This will allow us to use our mouse and keyboard from the VM once we boot it.

#### Launching the VM and installing graphics drivers

The time has finally come to boot up our VM. If all goes well, your screen should turn black and your VM should start booting in fullscreen. You'll most likely notice that your screen resolution is stretched and out of place. You'll probably also not be able to change the resolution manually in the Windows settings.

This is because you need to install the correct graphics drivers for your GPU. These can usually be installed by going to the **Settings** and then **Updates & Security**. Check for updates, and if Windows can find the right drivers, it'll install them. If not, you can find your GPU's drivers on the website of the hardware manufacturer.
