#! /bin/bash
# This script has to be executed after a chroot

cd /usr/local/bin
rm -rf arch-linux-server
git clone https://github.com/jaapjansma/arch-linux-server.git

new_hostname=`cat /root/config/hostname`
admin_email=`cat /root/config/admin_email`
admin_username=`cat /root/config/admin_username`
admin_user_email=`cat /root/config/admin_user_email`

ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc --utc

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

systemctl enable dhcpcd@ens3.service
systemctl start dhcpcd@ens3.service

touch /etc/iptables/iptables.rules
systemctl enable iptables
systemctl start iptables

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

echo "%wheel      ALL=(ALL) ALL" >> /etc/sudoers
systemctl enable sshd
systemctl start sshd

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
useradd -m -G wheel ${admin_username}
mkdir -p /home/${admin_username}/.ssh
if [ -f "arch-linux-server/public_keys/${admin_username}/id_rsa.pub" ]
then
  cp arch-linux-server/public_keys/${admin_username}/id_rsa.pub /home/${admin_username}/.ssh/authorized_keys
fi  
chown -R ${admin_username}:${admin_username} /home/${admin_username}/.ssh

random_passwd_root=$(cat /dev/urandom | tr -dc "a-zA-Z0-9!@#$%^&*()_+?><~\;" | fold -w 32 | head -n 1)
random_passwd_user=$(cat /dev/urandom | tr -dc "a-zA-Z0-9!@#$%^&*()_+?><~\;" | fold -w 32 | head -n 1)
echo -e "root:$random_passwd_root" | chpasswd
echo -e "$admin_username:$random_passwd_user" | chpasswd

mkdir /root/mails
echo "root@$new_hostname
$admin_email
New server ready
Your server is ready below are your login details.

Login with ssh at $new_hostname
User: $admin_username
Password: $random_passwd_user

Root passwd: $random_passwd_root

" > /root/mails/newserver.email

echo echo ${admin_email} >> /root/.forward
echo echo ${admin_user_email} >> /home/jaap/.forward
chown ${admin_username}:${admin_username} /home/jaap.forward


cp arch-linux-server/config/etc/systemd/system/post-installation.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable post-installation.service
