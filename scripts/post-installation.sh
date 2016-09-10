#! /bin/bash

systemctl mask tmp.mount
umount /tmp

new_hostname=`cat /root/config/hostname`
hostnamectl set-hostname ${new_hostname}

python3 /usr/local/bin/arch-linux-server/scripts/send-email-from-dir.py --directory=/root/mails

systemctl disable post-installation.service
rm -rf /etc/systemd/system/post-installation.service
systemctl daemon-reload
