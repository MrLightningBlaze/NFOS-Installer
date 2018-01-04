#!/bin/bash

#####################
#NFOS Setting File  #
#Written By LBlaze  #
#####################

##Username and Hostname Data
username=""
hostname=""

##Basic Settings
EDITOR="nano"
export EDITOR="nano"
langfile="en_US.UTF-8"
timezone="UTC"

##Drive Settings
mountpoint="/mnt"
drive=
bootDrive=
rootDrive=

##Application Packages
coreStuff="grub efibootmgr sudo"
networkStuff="iw wpa_supplicant dialog dhcpcd networkmanager network-manager-applet"
xorgDesktop="xorg-server xorg-drivers xfce4 lxdm pulseaudio pulseaudio-alsa"
defaultApps="firefox rxvt-unicode gedit pavucontrol"
gamingPackage="steam discord wine wine_gecko wine-mono"
officePackage="libreoffice thunderbird"

## OpenRC Stuff ##
openRCPackages="base base-devel openrc-system grub linux-lts linux-lts-headers systemd-dummy libsystemd-dummy openrc-world openrc netifrc mkinitcpio"
openRCServicePackages="acpid-openrc alsa-utils-openrc autofs-openrc displaymanager-openrc fuse-openrc haveged-openrc hdparm-openrc syslog-ng-openrc"
openRCServices="acpid alsasound autofs xdm fuse haveged hdparm syslog-ng dbus"

## Post-Install Added Settings ##

