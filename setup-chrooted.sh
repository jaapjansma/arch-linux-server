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
systemctl enable systemd-resolved 
systemctl start systemd-resolved
systemctl enable systemd-networkd.service
systemctl start systemd-networkd.service

echo "[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf

pacman --noconfirm -Sy vim grub sudo openssh yaourt

mkinitcpio -p linux

grub-install --target=i386-pc /dev/vda
grub-mkconfig -o /boot/grub/grub.cfg

echo "%wheel      ALL=(ALL) ALL" >> /etc/sudoers
systemctl enable sshd

useradd -m -G wheel jaap
passwd jaap
passwd

