#! /bin/bash

cd /usr/local/bin/arch-linux-server

hostname="$(hostname)"

webserver/mysql.sh
webserver/nginx.sh
webserver/php56-fpm.sh
webserver/nginx_php56.sh

sudo systemctl reload nginx
