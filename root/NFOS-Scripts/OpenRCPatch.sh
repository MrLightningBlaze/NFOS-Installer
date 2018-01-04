#!/bin/bash

################################
#NFOS Installer OpenRC Patch   #
#Written By LBlaze             #
################################

source /NFOS-Data/settings.sh

## Prepare the repositories ##
cp /NFOS-Data/pacman.conf /etc/pacman.conf
rm /NFOS-Data/pacman.conf

## Update the mirrorlists ##
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-arch
cat > /etc/pacman.d/mirrorlist <<EOF
 # Worldwide mirrors
 Server = https://mirrors.dotsrc.org/artix-linux/repos/\$repo/os/\$arch
 Server = http://mirror.strits.dk/artix-linux/repos/\$repo/os/\$arch
 Server = https://artix.mief.nl/repos/\$repo/os/\$arch
 Server = http://mirror1.artixlinux.org/artix-linux/repos/\$repo/os/\$arch
EOF


## Clean up the packages cache ##
pacman -Scc --noconfirm
pacman -Syy --noconfirm


## Install the Artix PGP keyring ##
echo -e "y\nn" | pacman -Sw artix-keyring
pacman -U /var/cache/pacman/pkg/artix-keyring-20171114-1-any.pkg.tar.xz --noconfirm
pacman-key --populate artix
pacman-key --lsign-key 78C9C713EAD7BEC69087447332E21894258C6105


## Download the Artix packages ##
pacman -Sw $openRCPackages --noconfirm --needed


## Remove systemd ##
pacman -Rdd systemd libsystemd --noconfirm


## Install OpenRC ##
echo -e "\n\n\n\n\n\ny\ny\n\n" | pacman -S $openRCPackages --force --needed


## Install init scripts ##
pacman -S $openRCServicePackages --needed --noconfirm


## Enable services ##
for daemon in $openRCServices; do rc-update add $daemon default; done
rc-update add udev boot
rc-update add elogind boot


## Remove more systemd cruft ##
for user in systemd-journal systemd-journal-gateway systemd-timesync systemd-network systemd-bus-proxy systemd-journal-remote systemd-journal-upload; do userdel $user; done


## Update the bootloader and the kernel initramfs ##
mkinitcpio -p linux-lts
if [ -d /sys/firmware/efi ]
then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub #Install Grub to System
else
    grub-install --target=i386-pc ${bootDrive::-1}
fi
echo 'DISPLAYMANAGER="lxdm"' > /etc/conf.d/xdm
rc-update add xdm default
