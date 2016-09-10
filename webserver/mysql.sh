#! /bin/bash

cd /usr/local/bin/arch-linux-server

hostname="$(hostname)"

# Install the neccesary packages
sudo pacman --noconfirm -Sq mariadb

# Configure MySQL
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

sudo systemctl enable mariadb
sudo systemctl start mariadb

mkdir /tmp/mails
random_passwd_root=$(cat /dev/urandom | tr -dc "a-zA-Z0-9!@#$%^&*()_+?><~\;" | fold -w 32 | head -n 1)
echo "root@$hostname
root@$hostname
MySQL Installations

Root passwd: $random_passwd_root

" > /tmp/mails/mysql.email

# Make sure that NOBODY can access the server without a password
mysql -u root -e "UPDATE mysql.user SET Password = PASSWORD('${random_passwd_root}') WHERE User = 'root'"
# Kill the anonymous users
mysql -u root -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
mysql -u root -e "DROP USER ''@'${hostname}'"
# Kill off the demo database
mysql -u root -e "DROP DATABASE test"
# Make our changes take effect
mysql -u root -e "FLUSH PRIVILEGES"

python3 /usr/local/bin/arch-linux-server/scripts/send-email-from-dir.py --directory=/tmp/mails
rm -rf /tmp/mails

# Make sure the port 3306 is only permitted from a local interface and not from outside.
sudo bash -c "iptables -A INPUT -i lo -p tcp --dport 3306 -j ACCEPT"
sudo bash -c "iptables -A INPUT -p tcp --dport 3306 -j DROP"
sudo bash -c "iptables-save > /etc/iptables.rules"

sudo systemctl restart iptables
