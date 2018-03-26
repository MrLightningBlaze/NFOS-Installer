#!/bin/bash

###########################
#NFOS Install Settings    #
#Written By LBlaze        #
###########################

#TODO Support Other Keyboard Layouts
#TODO Better Lang Selector
#TODO Theme Installation

source /root/Data/settings.sh

##Functions##

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
            bootDrive="$drive"1
            rootDrive="$drive"2
            fullDrive=true
            echo
            read -r -p "The drive $drive will be wiped, are you sure? [y/N]" response #Confirm the settings with the user
            case "$response" in
                [yY][eE][sS]|[yY])
                        SetSettings fullDrive #Save drive settings
                        SetSettings drive 
                        SetSettings rootDrive 
                        SetSettings bootDrive 
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
        fullDrive=false
        if [ -b "$rootDrive" ]; then
            if [ -b "$bootDrive" ]; then
                read -r -p "$rootDrive will be used as root and $bootDrive will be used as Boot, are you sure? [y/N]" response #Confirm the settings with the user
                case "$response" in
                    [yY][eE][sS]|[yY])
                        SetSettings fullDrive #Save drive settings
                        SetSettings rootDrive 
                        SetSettings bootDrive 
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
echo
echo "Welcome to the Installer!"
echo "You will be asked for several settings before the installer begins"
echo "Afterward the installer will run, and install your OS"
echo 
echo

YesNo "Are you using Wifi? [y/N]" "wifi-menu" "dhcpcd -q"

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

## Ask User about Extra Scripts ##
YesNo "Do you wish to install one of the Custom Application Packages (Gaming/Office/Developing/Etc)? [y/N]" "export AppPackages=true" "export AppPackages=false"
YesNo "Do you wish to replace Systemd with OpenRC? [y/N]" "export OpenRC=true" "export OpenRC=false"
SetSettings AppPackages
SetSettings OpenRC

## Run Actual Install ##
/root/Installer.sh

##Cleanup## 
umount "$bootDrive" #Unmount Boot Drive
umount "$rootDrive" #Unmount Root Drive
reboot
