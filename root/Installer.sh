#!/bin/bash

###########################
#NFOS Install Script      #
#Written By LBlaze        #
###########################

source /root/Data/settings.sh


#TODO Partition drive if its full drive install
if $fullDrive; then
    if [ -d /sys/firmware/efi ]; then
        echo -e "o\nn\n\n\n\n+1G\nn\n\n\n\n\nt\n1\nef\nw" | fdisk $drive #Partition the Disk
    else
        echo -e "o\nn\n\n\n\n+1G\nn\n\n\n\n\nw" | fdisk $drive #Partition the Disk
    fi
fi

##Main Install##
timedatectl set-ntp true #Enable Network Time
mkfs.fat -F32 "$bootDrive" #Format Boot Partition
mkfs.ext4 "$rootDrive" #Format Root Partition
mount "$rootDrive" "$mountpoint" #Mount Root Partition
mkdir "$mountpoint"/boot #Create Boot Mountpoint
mount "$bootDrive" "$mountpoint"/boot #Mount Boot Partition
pacstrap "$mountpoint" base base-devel #Install Core System
genfstab -U "$mountpoint" >> "$mountpoint"/etc/fstab #Generate the fstab
echo "LANG=$langfile" >> $mountpoint/etc/locale.conf
echo "$hostname" >> $mountpoint/etc/hostname #Set The Hostname


##Chroot Setup##
arch-chroot $mountpoint ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime #Set the timezone
arch-chroot $mountpoint hwclock --systohc #Set the hardware clock to UTC
arch-chroot $mountpoint locale-gen #Generate Locales
arch-chroot $mountpoint pacman -S $coreStuff $networkStuff $xorgDesktop $defaultApps --noconfirm

if [ -d /sys/firmware/efi ]
then
    arch-chroot $mountpoint grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub #Install Grub to System
else
    arch-chroot $mountpoint grub-install --target=i386-pc ${bootDrive::-1}
fi

arch-chroot $mountpoint grub-mkconfig -o /boot/grub/grub.cfg #Configure Grub
arch-chroot $mountpoint useradd -m -G wheel -s /bin/bash "$username" #Create User
arch-chroot $mountpoint systemctl enable dhcpcd
arch-chroot $mountpoint systemctl enable lxdm
echo "%wheel ALL=(ALL) ALL" >> $mountpoint/etc/sudoers
echo "%root ALL=(ALL:ALL) ALL" >> $mountpoint/etc/sudoers
echo "[multilib]" >> $mountpoint/etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> $mountpoint/etc/pacman.conf
arch-chroot $mountpoint pacman -Syy --noconfirm
clear

##Final User Config##
read -n 1 -s -r -p "Note: User interaction required. Press any key to continue" #Ask User For Passwords
echo
echo "You will now be asked for the password for \"root\""
arch-chroot $mountpoint passwd
echo "You will now be asked for the password for \"$username\""
arch-chroot $mountpoint passwd "$username"

## Run post-Install Scripts ##
#Copy Scripts
mkdir "$mountpoint"/NFOS-Data
mkdir "$mountpoint"/NFOS-Scripts
cp /root/Data/settings.sh "$mountpoint"/NFOS-Data/settings.sh
cp /root/Data/Configs/pacman.conf "$mountpoint"/NFOS-Data/pacman.conf
cp -r /root/NFOS-Scripts/* "$mountpoint"/NFOS-Scripts/

#Install Pacaur
arch-chroot "$mountpoint" /NFOS-Scripts/pacaurInstall.sh
rm "$mountpoint"/NFOS-Scripts/pacaurInstall.sh

#Run Application Package Installer
if $AppPackages; then
    arch-chroot $mountpoint /NFOS-Scripts/ApplicationPackages.sh
fi
rm "$mountpoint"/NFOS-Scripts/ApplicationPackages.sh

if $OpenRC; then
    arch-chroot $mountpoint /NFOS-Scripts/OpenRCPatch.sh
fi
rm "$mountpoint"/NFOS-Scripts/OpenRCPatch.sh

##Cleanup##
sync #Sync data to disks

