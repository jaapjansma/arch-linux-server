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

systemctl enable dhcpcd@ens3.service
systemctl start dhcpcd@ens3.service

sudo systemctl enable iptables
sudo systemctl start iptables

echo "[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf

pacman --noconfirm -Sy vim grub sudo openssh openssl yaourt certbot python3

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
read new_hostname
#new_hostname="$(new_hostname)"
hostnamectl set-hostname $new_hostname
mkdir /root/config
echo "$new_hostname" >> /root/config/hostname

# Install outgoing mailserver
arch-linux-server/mailserver/only_outgoing.sh

# Create a default certificate
certbot certonly --standalone -d $new_hostname --email $admin_email --agree-tos
ln -s /etc/letsencrypt/live/$new_hostname /etc/letsencrypt/root
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
echo "root@$new_hostname
$admin_email
New server ready
Your server is ready below are your login details.

Login with ssh at $new_hostname
User: jaap
Password: $random_passwd_jaap

Root passwd: $random_passwd_root

" > /root/mails/newserver.email


cp arch-linux-server/config/etc/systemd/system/post-installtion.service /etc/systemd/system/post-installation.service
systemctl daemon-reload
systemctl enable send-emails.service



