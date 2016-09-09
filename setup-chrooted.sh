#! /bin/bash
# This script has to be executed after a chroot

cd /usr/local/bin
rm -rf arch-linux-server
git clone https://github.com/jaapjansma/arch-linux-server.git

admin_email=admin@edeveloper.nl

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
mkdir /etc/skel/www
echo "export PATH=\$PATH:~/bin" >> /etc/skel/.bashrc

echo "%wheel      ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
systemctl enable sshd
systemctl start sshd

# Set Hostname
echo "What is the hostname?"
read hostname
hostnamectl set-hostname $hostname
hostname="$(hostname)"

# Install outgoing mailserver
arch-linux-server/mailserver/only_outgoing.sh

# Create a default certificate
certbot certonly --standalone -d $hostname --email $admin_email --agree-tos
ln -s /etc/letsencrypt/live/$hostname /etc/letsencrypt/root
cp arch-linux-server/config/etc/systemd/system/certbot.timer /etc/systemd/system/certbot.timer
cp arch-linux-server/config/etc/systemd/system/certbot.service /etc/systemd/system/certbot.service
systemctl daemon-reload
systemctl enable certbot.timer
systemctl start certbot.timer

# Add users
useradd -m -G wheel jaap
mkdir -p /home/jaap/.ssh
cp arch-linux-server/public_keys/jaap/id_rsa.pub /home/jaap/.ssh/authorized_keys
chown -R jaap:jaap /home/jaap/.ssh

random_passwd_root="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)"
random_passwd_jaap="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)"
echo "$random_passwd_root" | passwd --stdin
passwd -d jaap
passwd -e jaap
passwd -e root

mkdir /root/mails
echo "info@edeveloper.nl
info@edeveloper.nl
New server ready
Your server is ready below are your login details.

Login with ssh at $hostname
User: jaap
Password: $random_passwd_jaap

Root passwd: $random_passwd_root

" > /root/mails/newserver.email


cp arch-linux-server/config/etc/systemd/system/send-emails.service /etc/systemd/system/send-emails.service
systemctl daemon-reload
systemctl enable send-emails.service



