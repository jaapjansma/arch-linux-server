#! /bin/sh
# This script has to be executed after a chroot

cd /root
git clone https://github.com/jaapjansma/arch-linux-server.git

ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc --utc

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
