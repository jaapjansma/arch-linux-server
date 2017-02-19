#! /bin/bash

sed -i 's/#disable_plaintext_auth = yes/disable_plaintext_auth = no/g' /etc/dovecot/conf.d/10-auth.conf
sed -i 's/!include auth-system.conf.ext/#!include auth-system.conf.ext/g' /etc/dovecot/conf.d/10-auth.conf
sed -i 's/#!include auth-sql.conf.ext/!include auth-sql.conf.ext/g' /etc/dovecot/conf.d/10-auth.conf

## Below needs to be updated
# POstfixadmin + Dovecot

# See https://github.com/geekinthesticks/ArchLinux-Mail-Server/blob/master/archlinux_mail_server.org

groupadd -g 5000 vmail
useradd -u 5000 -g vmail -s /sbin/nologin -d /home/vmail -m vmail
chmod 750 /home/vmail

random_passwd_postfix=$(cat /dev/urandom | tr -dc "a-zA-Z0-9!@#$%^&*()_+?><~\;" | fold -w 32 | head -n 1)

echo "
driver = mysql
connect = host=localhost dbname=postfix user=postfix password=$random_passwd_postfix
default_pass_scheme = SHA512-CRYPT
user_query = SELECT '/home/vmail/%d/%u' as home, 'maildir:/home/vmail/%d/%u' as mail, 5000 AS uid, 5000 AS gid, concat('dirsize:storage=',  quota) AS quota FROM mailbox WHERE username = '%u' AND active = '1'
password_query = SELECT username as user, password, '/home/vmail/%d/%u' as userdb_home, 'maildir:/home/vmail/%d/%u' as userdb_mail, 5000 as  userdb_uid, 5000 as userdb_gid FROM mailbox WHERE username = '%u' AND active = '1'
" >> /etc/dovecot/dovecot-sql.conf

yaourt -S --no-confirm PostfixAdmin
