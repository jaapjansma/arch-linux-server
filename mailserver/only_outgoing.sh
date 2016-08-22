#! /bin/bash

sudo pacman -S postfix

sudo echo "
# Simple spam prevention. Taken from http://www.netarky.com/programming/arch_linux/Arch_Linux_mail_server_setup_1.html
smtpd_helo_required = yes
smtpd_helo_restrictions = reject_non_fqdn_helo_hostname, reject_unknown_helo_hostname
smtpd_delay_reject = yes" >> /etc/postfix/main.cf

sudo echo "
# Person who should get root's mail. Don't receive mail as root!
root:   jaap
spam:   jaap
ham:    jaap
jaap:   info@edeveloper.nl
" >> /etc/postfix/aliases

sudo systemctl enable postfix
sudo systemctl start postfix
