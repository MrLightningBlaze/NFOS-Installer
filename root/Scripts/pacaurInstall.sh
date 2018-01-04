#!/bin/bash

##PreSetup

source /settings.sh

mkdir PacaurSetup
chmod -R 777 /PacaurSetup
cd PacaurSetup
pacman -S expac yajl git base-devel --needed --noconfirm

sudo -u $username gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
sudo -u $username gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53

##Download And Ready Files
sudo -u $username curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz
sudo -u $username curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz
sudo -u $username tar -xvf cower.tar.gz
sudo -u $username tar -xvf pacaur.tar.gz


##Install Cower
cd cower
sudo -u $username makepkg
pacman -U *.pkg.tar.xz --noconfirm

##Install Pacaur
cd ../pacaur
sudo -u $username makepkg
pacman -U *.pkg.tar.xz --noconfirm

##Cleanup
cd ../..
rm -Rf PacaurSetup
