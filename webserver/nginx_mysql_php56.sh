#! /bin/bash

cd dirname $0
cd ..

# Install the neccesary packages
sudo pacman --noconfirm -Sq mariadb nginx

# Configure MySQL
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

sudo systemctl enable mariadb
sudo systemctl start mariadb

sudo mysql_secure_installation

# Make sure the port 3306 is only permitted from a local interface and not from outside.
sudo iptables -A INPUT -i lo -p tcp --dport 3306 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 3306 -j DROP
sudo iptables-save > /etc/iptables/iptables.rules

sudo systemctl restart iptables

# Install PHP5.6
gpg --keyserver hkp://hkps.pool.sks-keyservers.net --recv-keys C2BF0BC433CFC8B3 FE857D9A90D90EC1 
yaourt -S --noconfirm php56-fpm

# Configure NGINX

sudo mkdir /etc/nginx/sites-available
sudo mkdir /etc/nginx/sites-enabled
sudo mkdir /etc/nginx/sites-default

sudo cp config/etc/nginx/nginx.conf /etc/nginx/nginx.conf

sudo cp config/etc/nginx/default-sites/default-http.conf /etc/nginx/default-sites/default-http.conf


