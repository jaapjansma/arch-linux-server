#! /usr/bin/python3

import os
import sys
import pwd
import argparse
import subprocess

parser = argparse.ArgumentParser(description="""
Creates a new website
""")
parser.add_argument("--url", help="The URL of the site e.g www.yoursite.com")
parser.add_argument("--username", help="Username for which we create the site", type=str, required=True)
parser.add_argument("--php56", help="Enable php 5.6, default set to false (php 7)", action='store_true' type=bool, default=False, required=False)
parser.add_argument("--directory", help="The directory which contains the website file", type=str, default="/home/[user]/www/[url]", required=False)
args = parser.parse_args()

url = args.url
url = url.replace('http://', '')
url = url.replace('https://', '')
username = args.username
root = args.directory
root = directory.replace('[url]', url)
root = directory.replace('[user]', username)
php56 = args.php56

if os.getenv("USER") == 'root':
    sys.exit("This script should be run as root. Abort")

phpFpmDaemon = 'php-fpm'
phpConfigDir = '/etc/php'
if php56:
    phpConfigDir = '/etc/php56'
    phpFpmDaemon = 'php56-fpm'

# Create a PHP-FPM Config file
phpFpmFilename = phpConfigDir + '/php-fpm.d/'+url+'.conf'
phpSocketName = '/run/php-fpm/'+url+'.sock'
phpFpmTemplateFile = open('/usr/local/bin/arch-linux-server/config/etc/php-fpm.d/template.conf')
phpFpmFile = open(phpFpmFilename, 'w')
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
nginxConfigFile = open('/etc/nginx/sites-available/'+url+'.conf', 'w')
nginxConfig = nginxTemplateFile.read();
nginxConfig = phpFpmConfig.replace('[root]', root)
nginxConfig = phpFpmConfig.replace('[username]', username)
nginxConfig = phpFpmConfig.replace('[site]', url)
nginxConfig = phpFpmConfig.replace('[socket]', phpSocketName)
nginxConfigFile.write(nginxConfig)
nginxTemplateFile.close();
nginxConfigFile.close()

# Create root directory
os.makedirs(root)
os.symlink('/etc/nginx/sites-available/'+url+'.conf', '/etc/nginx/sites-enabled/'+url+'.conf')
subprocess.call(["systemctl", "reload", phpFpmDaemon])
subprocess.call(["systemctl", "reload", "nginx"])
