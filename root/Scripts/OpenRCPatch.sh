#!/bin/bash

source /root/Data/settings.sh

## Prepare the repositories ##
cp /root/Data/Configs/pacman.conf $mountpoint/etc/pacman.conf


## Update the mirrorlists ##
mv $mountpoint/etc/pacman.d/mirrorlist $mountpoint/etc/pacman.d/mirrorlist-arch
cat > $mountpoint/etc/pacman.d/mirrorlist <<EOF
 # Worldwide mirrors
 Server = https://mirrors.dotsrc.org/artix-linux/repos/\$repo/os/\$arch
 Server = http://mirror.strits.dk/artix-linux/repos/\$repo/os/\$arch
 Server = https://artix.mief.nl/repos/\$repo/os/\$arch
 Server = http://mirror1.artixlinux.org/artix-linux/repos/\$repo/os/\$arch
EOF


## Clean up the packages cache ##
arch-chroot $mountpoint pacman -Scc --noconfirm
arch-chroot $mountpoint pacman -Syy --noconfirm


## Install the Artix PGP keyring ##
echo -e "y\nn" | arch-chroot $mountpoint pacman -Sw artix-keyring
arch-chroot $mountpoint pacman -U /var/cache/pacman/pkg/artix-keyring-20171114-1-any.pkg.tar.xz --noconfirm
arch-chroot $mountpoint pacman-key --populate artix
arch-chroot $mountpoint pacman-key --lsign-key 78C9C713EAD7BEC69087447332E21894258C6105


## Download the Artix packages ##
arch-chroot $mountpoint pacman -Sw $openRCPackages --noconfirm --needed


## Remove systemd ##
arch-chroot $mountpoint pacman -Rdd systemd libsystemd --noconfirm


## Install OpenRC ##
echo -e "\n\n\n\n\n\ny\ny\n\n" | arch-chroot $mountpoint pacman -S $openRCPackages --force --needed


## Install init scripts ##
arch-chroot $mountpoint pacman -S $openRCServicePackages --needed --noconfirm


## Enable services ##
for daemon in $openRCServices; do arch-chroot $mountpoint rc-update add $daemon default; done
arch-chroot $mountpoint rc-update add udev boot
arch-chroot $mountpoint rc-update add elogind boot
arch-chroot $mountpoint rc-update add dbus default


## Remove more systemd cruft ##
for user in systemd-journal systemd-journal-gateway systemd-timesync systemd-network systemd-bus-proxy systemd-journal-remote systemd-journal-upload; do arch-chroot $mountpoint userdel $user; done


## Update the bootloader and the kernel initramfs ##
arch-chroot $mountpoint mkinitcpio -p linux-lts
if [ -d /sys/firmware/efi ]
then
    arch-chroot $mountpoint grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub #Install Grub to System
else
    arch-chroot $mountpoint grub-install --target=i386-pc ${bootDrive::-1}
fi
echo 'DISPLAYMANAGER="lxdm"' > $mountpoint/etc/conf.d/xdm
arch-chroot $mountpoint rc-update add xdm default
