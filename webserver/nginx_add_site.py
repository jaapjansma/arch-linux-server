#! /usr/bin/python3

import os
import sys
import pwd
import argparse
import subprocess
import shutil
import socket

parser = argparse.ArgumentParser(description="""
Creates a new website
""")
parser.add_argument("url", help="The URL of the site e.g www.yoursite.com", type=str)
parser.add_argument("username", help="Username for which we create the site", type=str)
parser.add_argument("--php56", help="Enable php 5.6, default set to false (php 7)", action='store_true', required=False)
parser.add_argument("--directory", help="The directory which contains the website files. Default to /var/www/[url]", type=str, default="/var/www/[url]", required=False)
args = parser.parse_args()

url = args.url
url = url.replace('http://', '')
url = url.replace('https://', '')
username = args.username
root = args.directory
root = root.replace('[url]', url)
root = root.replace('[user]', username)
php56 = args.php56

if os.getenv("USER") != 'root':
    sys.exit("This script should be run as root. Abort")

if os.path.exists(root):
    sys.exit("Looks like this site alrady exists on your system (check: " + root + ")")

admin_email = "root@" + socket.gethostname()
subprocess.call(["certbot", "certonly", "--webroot", "-w /usr/share/nginx/html", "-d " + url, "--email "+admin_email, "--agree-tos"])

phpFpmDaemon = 'php-fpm'
phpConfigDir = '/etc/php'
phpFpmFilename = phpConfigDir + '/php-fpm.d/'+url+'.conf'
phpSocketName = '/run/php-fpm/'+url+'.sock'
if php56:
    phpConfigDir = '/etc/php56'
    phpFpmDaemon = 'php56-fpm'
    phpFpmFilename = phpConfigDir + '/fpm.d/'+url+'.conf'
    phpSocketName = '/run/php56-fpm/'+url+'.sock'

# Create a PHP-FPM Config file
phpFpmTemplateFile = open('/usr/local/bin/arch-linux-server/config/etc/php-fpm.d/template.conf')
phpFpmFile = open(phpFpmFilename, "w")
phpFpmConfig = phpFpmTemplateFile.read()
phpFpmConfig = phpFpmConfig.replace('[root]', root)
phpFpmConfig = phpFpmConfig.replace('[username]', username)
phpFpmConfig = phpFpmConfig.replace('[site]', url)
phpFpmConfig = phpFpmConfig.replace('[socket]', phpSocketName)
phpFpmFile.write(phpFpmConfig)
phpFpmFile.close()
phpFpmTemplateFile.close()

# Create the NGINX site Config
nginxTemplateFile = open('/usr/local/bin/arch-linux-server/config/etc/nginx/sites-available/template.conf')
nginxConfigFile = open('/etc/nginx/sites-available/'+url+'.conf', "w")
nginxConfig = nginxTemplateFile.read();
nginxConfig = nginxConfig.replace('[root]', root)
nginxConfig = nginxConfig.replace('[username]', username)
nginxConfig = nginxConfig.replace('[url]', url)
nginxConfig = nginxConfig.replace('[socket]', phpSocketName)
nginxConfigFile.write(nginxConfig)
nginxTemplateFile.close();
nginxConfigFile.close()

# Create root directory
os.makedirs(root)
shutil.chown(root, username, username)
os.chmod(root, stat.S_IXOTH)
os.symlink('/etc/nginx/sites-available/'+url+'.conf', '/etc/nginx/sites-enabled/'+url+'.conf')
subprocess.call(["systemctl", "reload", phpFpmDaemon])
subprocess.call(["systemctl", "reload", "nginx"])
