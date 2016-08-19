#! /usr/bin/sh
parted /dev/vda -s mklabel msdos
parted /dev/vda -s mkpart primary ext4 1MiB 30GiB
parted /dev/vda -s set 1 boot on
parted /dev/vda -s mkpart primary ext4 30GiB 100%

mkfs.ext4 /dev/vda1
mkfs.ext4 /dev/vda2

mount /dev/vda1 /mnt
mkdir /mnt/home
mount /dev/vda2 /mnt/home

pacstrap /mnt base base-devel git

genfstab -p /mnt >> /mnt/etc/fstab

wget https://github.com/jaapjansma/arch-linux-server/raw/master/setup-chrooted.sh -O /mnt/root/setup-chrooted.sh
chmod u+x /mnt/root/setup-chrooted.sh
arch-chroot /mnt /root/setup-chrooted.sh

reboot
