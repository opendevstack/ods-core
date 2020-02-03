#!/usr/bin/env bash
set -e

sudo yum install -y wget gcc kernel-devel-$(uname -r) kernel-headers-$(uname -r) dkms make bzip2 perl
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

VBOX_LATEST_VERSION=$(curl http://download.virtualbox.org/virtualbox/LATEST.TXT)
sudo wget -c http://download.virtualbox.org/virtualbox/${VBOX_LATEST_VERSION}/VBoxGuestAdditions_${VBOX_LATEST_VERSION}.iso -O /tmp/VBoxGuestAdditions_${VBOX_LATEST_VERSION}.iso
sudo mkdir -p /media/guestadditions ; sudo mount -o loop /tmp/VBoxGuestAdditions_${VBOX_LATEST_VERSION}.iso /media/guestadditions
sudo yes | /media/guestadditions/VBoxLinuxAdditions.run
sudo umount /media/guestadditions && sudo rm -rf /tmp/VBoxGuestAdditions_$VBOX_VERSION.iso /media/guestadditions

sudo cat /var/log/vboxadd-setup.log

echo 'You may safely ignore the message that reads: "Could not find the X.Org or XFree86 Window System."'
