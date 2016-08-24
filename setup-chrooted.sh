#! /bin/sh
# This script has to be executed after a chroot

cd /usr/local/bin
rm -rf arch-linux-server
git clone https://github.com/jaapjansma/arch-linux-server.git

ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc --utc

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

cat /root/confif/hostname > /etc/hostname

systemctl enable dhcpcd@ens3.service
systemctl start dhcpcd@ens3.service

sudo systemctl enable iptables
sudo systemctl start iptables

echo "[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf

pacman --noconfirm -Sy vim grub sudo openssh openssl yaourt certbot

mkinitcpio -p linux

grub-install --target=i386-pc /dev/vda
grub-mkconfig -o /boot/grub/grub.cfg

mkdir /var/yaourt
chmod a+w /var/yaourt
sed -i 's/#TMPDIR="\/tmp"/TMPDIR="/var/yaourt"/g' /etc/yaourtrc

mkdir /etc/skel/tmp
mkdir /etc/skel/bin
echo "export PATH=\$PATH:~/bin" >> /etc/skel/.bashrc

echo "%wheel      ALL=(ALL) ALL" >> /etc/sudoers
systemctl enable sshd

# Set Hostname
echo "What is the hostname?"
read hostname
hostnamectl set-hostname $hostname
hostname="$(hostname)"

# Create a default certificate
sudo certbot certonly --standalone -d $(hostname) --email admin@edeveloper.nl --agree-tos
cp arch-linux-server/config/etc/systemd/system/certbot.timer /etc/systemd/system/certbot.timer
cp arch-linux-server/config/etc/systemd/system/certbot.service /etc/systemd/system/certbot.service
sudo systemctl daemon-reload
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

useradd -m -G wheel jaap
passwd jaap
passwd

