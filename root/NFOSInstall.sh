#!/bin/bash

###########################
#NFOS Install Script      #
#Written By LBlaze        #
###########################

#TODO Support Other Keyboard Layouts
#TODO Better Lang Selector
#TODO Theme Installation

source /root/Data/settings.sh

##Functions##
function PrintNFIcon ##Prints Out The Logo
{
    echo -e '                        `.--::///////::-.`                             '
    echo -e '                 `-/+shdmNNNNMMMMMMMMMNNNmmhs+:.`                      '
    echo -e '             .:ohmNMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmy+-`                  '
    echo -e '          .+hNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNdo-                '
    echo -e '         +NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMdyso++++ossydmmd+`             '
    echo -e '       `+NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMh-`          ``.-/+-            '
    echo -e '     `:hMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmhs+-./-         `            '
    echo -e '    `-omMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmdNy-                    '
    echo -e '       oMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNs`                  '
    echo -e '      `dMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd+`                '
    echo -e '     `yMMMMMMMMMMNMMMMMMMMMMMMMMMMMMdyo+/::/+shmNMMooNd:               '
    echo -e '    .sho/+NMMMMmoyMMMMMMMMMMMMMMd++++oosyyso/-..-/ydhNMm`              '
    echo -e '   ./-    yMMMy..NMMMMMMMMMMMMN+`    `  `.-/sddho-`.:ymm.              '
    echo -e '   `      hMm/` yMMMMMMMMMMMMN:    .os:::///.`-+dNd+` ..               '
    echo -e '         `Nd-  :MMMMMMMMMMMMmoo+::smMMMMMMMM/.` `/mMh-                 '
    echo -e '         oy`  `dMMMMMMMMMMMM+  `.:+ymNMMMMNNNmhs/--mMd`                '
    echo -e '        `+`   /ymMMMMMMMMMMM+       `-/ys:---::/+ssmMM/                '
    echo -e '        .     . -MMMMMMMMMMMd`                   `oMMNy:`              '
    echo -e '                 mMMMMMMMMMMMd:`               `:hMMN+`--              '
    echo -e '                 ymshNMMMMMMMMMdo-.`       ``-+hNMMm/                  '
    echo -e '                 //  -yNMMMMMMMMMMNdhysssyhdmMMMNm+`                   '
    echo -e '                 ``    .+hNMMMMMMMMMMMMMMMMMNNds:`                     '
    echo -e '                          .:oydNNNNNNNNNmhs+:.                         '
    echo -e '                               ``.---.``                               '
}

function YesNo ##Function for dynamic Yes/No options
{
    read -r -p "$1" askresult #Ask User Yes/No
    case "$askresult" in
        [yY][eE][sS]|[yY]) 
            $2
            ;;
        *)
            $3
            ;;
    esac
}


function SetSettings
{
    sed -i "/^$1=/c\\$1=\"$(eval echo \${$1})\"" /root/Data/settings.sh
}

function FullDriveInstall #Install To Entire Drive
{
    while true #Ask user to select drive
    do
        lsblk --output NAME,SIZE -d |grep "sd[a-z]"
        read -r -p "Please enter a disk to install to: " drive
        drive="/dev/$drive"
        if [ -b "$drive" ]; then
            SetSettings drive #Save drive in settings file
            bootDrive="$drive"1
            rootDrive="$drive"2
            SetSettings rootDrive #Save rootDrive in settings file
            SetSettings bootDrive #Save bootDrive  in settings file
            echo
            read -r -p "The drive $drive will be wiped, are you sure? [y/N]" response #Confirm the settings with the user
            case "$response" in
                [yY][eE][sS]|[yY])
                    if [ -d /sys/firmware/efi ]
                    then
                        echo -e "o\nn\n\n\n\n+1G\nn\n\n\n\n\nt\n1\nef\nw" | fdisk $drive #Partition the Disk
                    else
                        echo -e "o\nn\n\n\n\n+1G\nn\n\n\n\n\nw" | fdisk $drive #Partition the Disk
                    fi

                    break
                    ;;
                *)
                    exit 1
                    ;;
            esac
        fi
        clear
        echo "ERROR: That Drive does not exist"
        echo
    done
}

function ManualPartInstall #Manually Choose Paritions
{
    while true #Ask user to select drive
    do
        lsblk --output NAME,SIZE |grep "sd[a-z]"
        read -r -p "Please select your root partition: " rootDrive
        read -r -p "Please select your EFI partition: " bootDrive
        rootDrive=/dev/"$rootDrive"
        bootDrive=/dev/"$bootDrive"
        if [ -b "$rootDrive" ]; then
            if [ -b "$bootDrive" ]; then
                read -r -p "$rootDrive will be used as root and $bootDrive will be used as Boot, are you sure? [y/N]" response #Confirm the settings with the user
                case "$response" in
                    [yY][eE][sS]|[yY])
                        break
                        ;;
                    *)
                        exit 1
                        ;;
                esac
            else
                clear
                echo "ERROR: Boot Partition does not exist ($bootDrive)"
                echo
            fi 
        else
            clear
            echo "ERROR: Root Partition does not exist ($rootDrive)"
            echo
        fi
    done
}

##Get User Settings##
PrintNFIcon
echo
echo "Welcome to the NightFury OS Installer!"
echo "You will be asked for several settings before the installer begins"
echo "Afterward the installer will run, and install your OS"
echo 
echo

YesNo "Are you using Wifi? [y/N]" "wifi-menu" "dhcpcd"

while true
do
    echo
    echo
    echo "Your available drives are:"
    lsblk --output NAME,SIZE  | grep "sd[a-z]" #List Drives For User
    echo
    echo "How do you wish to install linux?"
    echo 
    echo "1) Install to an entire disk"
    echo "2) Select Existing Partitions"
    echo "3) Drop Back to Shell"
    echo
    read -r -p "Please enter your option:" driveoption #Confirm the settings with the user
    case "$driveoption" in
        1) 
            FullDriveInstall
            break
            ;;
        2)
            ManualPartInstall
            break
            ;;
        3)
            exit 1
            ;;
        *)
            echo "Please enter 1, 2, or 3"
            echo
            ;;
    esac
done


while true # Ask the user for Username and Hostname, loop untill they confirm
do
    echo
    echo "Please enter the username you wish to have, no spaces or uppercase: "
    read -r username
    username="$(echo -e "${username}" | tr -d '[:space:]')" #Remove Spaces From Username
    echo
    echo "Now please enter what you wish to name this computer, no spaces (Your Hostname): "
    read -r hostname
    hostname="$(echo -e "${hostname}" | tr -d '[:space:]')" #Remove Spaces From Hostname
    echo
    echo
    echo "Your username is: $username"
    echo "Your hostname is: $hostname"
    read -r -p "Is that correct? [y/N] " response #Confirm the settings with the user
    case "$response" in
        [yY][eE][sS]|[yY]) 
            break
            ;;
        *)
            ;;
    esac
done

SetSettings username #Save username in settings file
SetSettings hostname #Save hostname in settings file
echo
echo
timezone=$(tzselect) #Set User Timezone
SetSettings timezone #Save timezone in settings file
clear

##Main Install##
timedatectl set-ntp true #Enable Network Time
mkfs.fat -F32 "$bootDrive" #Format Boot Partition
mkfs.ext4 "$rootDrive" #Format Root Partition
mount "$rootDrive" "$mountpoint" #Mount Root Partition
mkdir "$mountpoint"/boot #Create Boot Mountpoint
mount "$bootDrive" "$mountpoint"/boot #Mount Boot Partition
pacstrap "$mountpoint" base base-devel #Install Core System
genfstab -U "$mountpoint" >> "$mountpoint"/etc/fstab #Generate the fstab
echo "LANG=$langfile" >> "$mountpoint"/etc/locale.conf
echo "$hostname" >> "$mountpoint"/etc/hostname #Set The Hostname


##Chroot Setup##
arch-chroot "$mountpoint" ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime #Set the timezone
arch-chroot "$mountpoint" hwclock --systohc #Set the hardware clock to UTC
arch-chroot "$mountpoint" locale-gen #Generate Locales
arch-chroot "$mountpoint" pacman -S "$coreStuff" "$networkStuff" "$xorgDesktop" "$defaultApps" --noconfirm

if [ -d /sys/firmware/efi ]
then
    arch-chroot "$mountpoint" grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub #Install Grub to System
else
    arch-chroot "$mountpoint" grub-install --target=i386-pc ${bootDrive::-1}
fi

arch-chroot "$mountpoint" grub-mkconfig -o /boot/grub/grub.cfg #Configure Grub
arch-chroot "$mountpoint" useradd -m -G wheel -s /bin/bash "$username" #Create User
arch-chroot "$mountpoint" systemctl enable dhcpcd
arch-chroot "$mountpoint" systemctl enable lxdm
echo "%wheel ALL=(ALL) ALL" >> "$mountpoint"/etc/sudoers
echo "%root ALL=(ALL:ALL) ALL" >> "$mountpoint"/etc/sudoers
echo "[multilib]" >> "$mountpoint"/etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> "$mountpoint"/etc/pacman.conf
arch-chroot "$mountpoint" pacman -Syy --noconfirm
clear


##Final User Config##
read -n 1 -s -r -p "Note: User interaction required. Press any key to continue" #Ask User For Passwords
echo
echo "You will now be asked for the password for \"root\""
arch-chroot "$mountpoint" passwd
echo "You will now be asked for the password for \"$username\""
arch-chroot "$mountpoint" passwd "$username"

## Run post-Install Scripts ##
#Copy Scripts
mkdir "$mountpoint"/NFOS-Data
mkdir "$mountpoint"/NFOS-Scripts
cp /root/Data/settings.sh "$mountpoint"/NFOS-Data/settings.sh
cp -r /root/NFOS-Scripts/* "$mountpoint"/NFOS-Scripts/
cp /root/Data/Configs/* "$mountpoint"/NFOS-Data/

#Install Pacaur
arch-chroot "$mountpoint" /NFOS-Scripts/pacaurInstall.sh
rm "$mountpoint"/NFOS-Scripts/pacaurInstall.sh

#Run Application Package Installer
YesNo "Do you wish to install one of the Custom Application Packages (Gaming/Office/Developing/Etc)? [y/N]" "arch-chroot $mountpoint /NFOS-Scripts/ApplicationPackages.sh" ""
rm "$mountpoint"/NFOS-Scripts/ApplicationPackages.sh

YesNo "Do you wish to replace Systemd with OpenRC? [y/N]" "arch-chroot $mountpoint /NFOS-Scripts/OpenRCPatch.sh" ""
rm "$mountpoint"/NFOS-Scripts/OpenRCPatch.sh


##Cleanup## 
umount "$bootDrive" #Unmount Boot Drive
umount "$rootDrive" #Unmount Root Drive
sync #Sync data to disks
reboot
