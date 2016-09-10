#! /bin/bash

cd /usr/local/bin/arch-linux-server

admin_email=`cat /root/config/admin_email`
admin_username=`cat /root/config/admin_username`
admin_user_email=`cat /root/config/admin_user_email`

sudo pacman --noconfirm -S postfix

sudo echo "
# Simple spam prevention. Taken from http://www.netarky.com/programming/arch_linux/Arch_Linux_mail_server_setup_1.html
smtpd_helo_required = yes
smtpd_helo_restrictions = reject_non_fqdn_helo_hostname, reject_unknown_helo_hostname
smtpd_delay_reject = yes" >> /etc/postfix/main.cf

sudo echo "
# Person who should get root's mail. Don't receive mail as root!
root:   $admin_email
spam:   $admin_username
ham:    $admin_username
$admin_username:   $admin_user_email
" >> /etc/postfix/aliases

newaliases

sudo systemctl enable postfix
sudo systemctl start postfix
