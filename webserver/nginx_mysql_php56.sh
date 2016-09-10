#! /bin/bash

cd /usr/local/bin/arch-linux-server

hostname="$(hostname)"

# Install the neccesary packages
sudo pacman --noconfirm -Sq mariadb nginx

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

# Install PHP5.6
gpg --keyserver hkp://hkps.pool.sks-keyservers.net --recv-keys C2BF0BC433CFC8B3 FE857D9A90D90EC1

yaourt -S --noconfirm php56-fpm

sudo sed -i 's/;extension=ftp.so/extension=ftp.so/g' /etc/php56/php.ini
sudo sed -i 's/;extension=gd.so/extension=gd.so/g' /etc/php56/php.ini
sudo sed -i 's/;extension=imap.so/extension=imap.so/g' /etc/php56/php.ini
sudo sed -i 's/;extension=intl.so/extension=intl.so/g' /etc/php56/php.ini
sudo sed -i 's/;extension=mysql.so/extension=mysql.so/g' /etc/php56/php.ini
sudo sed -i 's/;extension=mysqli.so/extension=mysqli.so/g' /etc/php56/php.ini
sudo sed -i 's/;extension=pdo_mysql.so/extension=pdo_mysql.so/g' /etc/php56/php.ini
sudo sed -i 's/;extension=phar.so/extension=phar.so/g' /etc/php56/php.ini
sudo sed -i 's/;extension=soap.so/extension=soap.so/g' /etc/php56/php.ini
sudo sed -i 's/;extension=tidy.so/extension=tidy.so/g' /etc/php56/php.ini
sudo sed -i 's/;extension=xmlrpc.so/extension=xmlrpc.so/g' /etc/php56/php.ini
sudo sed -i 's/;extension=zip.so/extension=zip.so/g' /etc/php56/php.ini
sudo sed -i 's/;date.timezone =/date.timezone = Europe\/Amsterdam/g' /etc/php56/php.ini

sudo sed -i 's/post_max_size = 8M/post_max_size = 128M/g' /etc/php56/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' /etc/php56/php.ini

sudo sed -i 's/;include=\/etc\/php56\/fpm.d\/*.conf/include=\/etc\/php56\/fpm.d\/*.conf/g' /etc/php56/php-fpm.conf

sudo systemctl enable php56-fpm
sudo systemctl start php56-fpm

# Configure NGINX

sudo mkdir /etc/nginx/sites-available
sudo mkdir /etc/nginx/sites-enabled
sudo mkdir /etc/nginx/sites-default

sudo cp config/etc/nginx/nginx.conf /etc/nginx/nginx.conf

sudo cp config/etc/nginx/sites-default/default-http.conf /etc/nginx/sites-default/default-http.conf
sudo sed -i 's/fastcgi_pass  unix:\/var\/run\/php-fpm\/php-fpm.sock;/fastcgi_pass  unix:\/var\/run\/php56-fpm\/php-fpm.sock;/g' /etc/nginx/sites-default/default-http.conf

sudo systemctl enable nginx
sudo systemctl start nginx

sudo ln -s scripts/reload-nginx.sh /usr/local/bin/reload-webserver.sh
sudo echo "ExecStartPost=/usr/local/bin/reload-webserver.sh" >> /etc/systemd/system/certbot.service
sudo systemctl daemon-reload

# Configure HTTPS
sudo mkdir -p /etc/nginx/ssl &&
sudo openssl rand 48 -out /etc/nginx/ssl/ticket.key &&
sudo openssl dhparam -out /etc/nginx/ssl/dhparam4.pem 4096

sudo cp config/etc/nginx/sites-default/default-https.conf /etc/nginx/sites-default/default-https.conf
sudo sed -i 's/#return 301 https:\/\/$host$request_uri;/return 301 https:\/\/$host$request_uri;/g' /etc/nginx/sites-default/default-http.conf
sudo sed -i 's/fastcgi_pass  unix:\/var\/run\/php-fpm\/php-fpm.sock;/fastcgi_pass  unix:\/var\/run\/php56-fpm\/php-fpm.sock;/g' /etc/nginx/sites-default/default-https.conf

sudo systemctl reload nginx

sudo chown -R http:http /usr/share/nginx/html
sudo chmod 0755 /usr/share/nginx/html
