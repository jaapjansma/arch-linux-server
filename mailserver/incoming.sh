#! /bin/bash

cd /usr/local/bin/arch-linux-server
sudo sed -i 's/inet_interfaces = loopback-only//g' /etc/postfix/main.cf

sudo pacman -S dovecot
sudo cp -r /usr/share/doc/dovecot/example-config/* /etc/dovecot/

sudo sed -i 's/#mail_location = /mail_location = maildir:~\nmail_home = \/home\/vmail\/%d\/%n/g' /etc/dovecot/conf.d/10-mail.conf
