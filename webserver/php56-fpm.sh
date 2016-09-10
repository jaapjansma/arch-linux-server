#! /bin/bash

cd /usr/local/bin/arch-linux-server

hostname="$(hostname)"

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
