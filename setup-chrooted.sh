#! /bin/sh
# This script has to be executed after a chroot

cd /root
rm -rf arch-linux-server
git clone https://github.com/jaapjansma/arch-linux-server.git

ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc --utc

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

cat /root/confif/hostname > /etc/hostname

cp arch-linux-server/config/etc/systemd/network/wired.network /etc/systemd/network/wired.network
systemctl enable systemd-networkd.service
systemctl start systemd-networkd.service

mkinitcpio -p linux

pacman --noconfirm -S vim grub sudo openssh

sed -i 's/#%wheel      ALL=(ALL) ALL/%wheel      ALL=(ALL) ALL/g' /etc/sudoers

grub-install --target=i386-pc /dev/vda
grub-mkconfig -o /boot/grub/grub.cfg

useradd -m -G wheel jaap
passwd jaap
passwd

