#! /bin/bash

cd /usr/local/bin/arch-linux-server

hostname="$(hostname)"

webserver/mysql.sh
webserver/nginx.sh
webserver/php56-fpm.sh

sudo sed -i 's/fastcgi_pass  unix:\/var\/run\/php-fpm\/php-fpm.sock;/fastcgi_pass  unix:\/var\/run\/php56-fpm\/php-fpm.sock;/g' /etc/nginx/sites-default/default-http.conf
sudo sed -i 's/fastcgi_pass  unix:\/var\/run\/php-fpm\/php-fpm.sock;/fastcgi_pass  unix:\/var\/run\/php56-fpm\/php-fpm.sock;/g' /etc/nginx/sites-default/default-https.conf

sudo systemctl reload nginx
