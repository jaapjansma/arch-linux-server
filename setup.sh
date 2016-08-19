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

pacstrap /dev base base-devel git

genfstab -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt
cd /root
git clone https://github.com/jaapjansma/arch-linux-server.git

ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc --utc

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
