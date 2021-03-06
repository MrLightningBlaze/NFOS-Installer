#!/bin/bash

#####################
#NFOS Setting File  #
#Written By LBlaze  #
#####################

##Username and Hostname Data
username="user"
hostname="host"

##Basic Settings
EDITOR="nano"
export EDITOR="nano"
langfile="en_US.UTF-8"
timezone="GMT"

##Drive Settings
mountpoint="/mnt"
fullDrive=""
drive=""
bootDrive=""
rootDrive=""

##Application Packages
coreStuff="grub efibootmgr sudo os-prober"
networkStuff="iw wpa_supplicant dialog dhcpcd networkmanager network-manager-applet"
xorgDesktop="xorg-server xorg-drivers xfce4 lxdm pulseaudio pulseaudio-alsa"
defaultApps="firefox rxvt-unicode gedit pavucontrol"
gamingPackage="steam discord wine wine_gecko wine-mono"
officePackage="libreoffice thunderbird"

## OpenRC Stuff ##
openRCPackages="base base-devel openrc-system grub linux-lts linux-lts-headers systemd-dummy libsystemd-dummy openrc-world openrc netifrc mkinitcpio"
openRCServicePackages="acpid-openrc alsa-utils-openrc autofs-openrc displaymanager-openrc fuse-openrc haveged-openrc hdparm-openrc syslog-ng-openrc ntp-openrc networkmanaget-openrc"
openRCServices="acpid alsasound autofs xdm fuse haveged hdparm syslog-ng dbus ntpd NetworkManager"

## Automated Install Stuff ##
AppPackages=false
OpenRC=false

## Post-Install Added Settings ##

