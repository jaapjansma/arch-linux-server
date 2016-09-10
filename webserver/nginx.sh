#! /bin/bash

cd /usr/local/bin/arch-linux-server

hostname="$(hostname)"

sudo pacman --noconfirm -Sq nginx

# Configure NGINX

sudo mkdir /etc/nginx/sites-available
sudo mkdir /etc/nginx/sites-enabled
sudo mkdir /etc/nginx/sites-default

sudo cp config/etc/nginx/nginx.conf /etc/nginx/nginx.conf

sudo cp config/etc/nginx/sites-default/default-http.conf /etc/nginx/sites-default/default-http.conf

sudo ln -s scripts/reload-nginx.sh /usr/local/bin/reload-webserver.sh
sudo echo "ExecStartPost=/usr/local/bin/reload-webserver.sh" >> /etc/systemd/system/certbot.service
sudo systemctl daemon-reload

# Configure HTTPS
sudo mkdir -p /etc/nginx/ssl &&
sudo openssl rand 48 -out /etc/nginx/ssl/ticket.key &&
sudo openssl dhparam -out /etc/nginx/ssl/dhparam4.pem 4096

sudo cp config/etc/nginx/sites-default/default-https.conf /etc/nginx/sites-default/default-https.conf
sudo sed -i 's/#return 301 https:\/\/$host$request_uri;/return 301 https:\/\/$host$request_uri;/g' /etc/nginx/sites-default/default-http.conf

sudo cp /usr/local/bin/arch-linux-server/webserver/favicon/favicon.ico /usr/share/nginx/html/
sudo chown -R http.http /usr/share/nginx/html
sudo chmod 0755 /usr/share/nginx/html

sudo systemctl enable nginx
sudo systemctl start nginx
