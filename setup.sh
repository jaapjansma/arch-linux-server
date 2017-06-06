#! /usr/bin/sh

mkdir config

# Set Hostname
echo "What is the hostname?"
read new_hostname
echo ${new_hostname} >> config/hostname

echo "What should be your username?"
read admin_username
echo ${admin_username} >> config/admin_username

echo "What is your e-mail address?"
read admin_user_email
echo ${admin_user_email} >> config/admin_user_email

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
cp -R config /mnt/root/config
arch-chroot /mnt /root/setup-chrooted.sh

reboot
