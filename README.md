# debian-custom-iso-builder
Scripts to build a custom iso for installing Debian based Linux systems that can be fully automated and require no manual intervention. Oriented around tasks that are hard to accomplish with the default installer, such as setting up a ZFS or BTRFS root filesystem with a custom layout and creating a minimal system to build off of.

These scripts make use debootstrap to build the resulting systems, this approach allows for the full customization of the system built and compatibility with any Debian based system. It will also be possible to easily adapt these tools to support Arch Linux based distributions. 
