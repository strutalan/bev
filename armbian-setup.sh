# Updates & prepares the armbian environment for mdns & samba
#! /bin/sh

sudo apt update && sudo apt upgrade
sudo apt install avahi-daemon samba

