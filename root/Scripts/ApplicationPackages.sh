#!/bin/bash

################################
#Pacaur application Installer  #
#Written By LBlaze             #
################################

source /root/Data/settings.sh

packagesToInstall=""

function YesNo ##Function for dynamic Yes/No options
{
    read -r -p "$1" askresult
    case "$askresult" in
        [yY][eE][sS]|[yY]) 
            eval $2
            ;;
        *)
            $3
            ;;
    esac
}

sudo -u $username gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
sudo -u $username gpg --recv-keys --keyserver hkp://pgp.mit.edu 0FC3042E345AD05D

YesNo "Do you wish to install the Gaming Package? [y/N] " "packagesToInstall=\"$packagesToInstall $gamingPackage\"" ""
YesNo "Do you wish to install the Office Package? [y/N] " "packagesToInstall=\"$packagesToInstall $officePackage\"" ""

sudo -u $username pacaur -S$packagesToInstall --noedit --noconfirm
