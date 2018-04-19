#!/bin/bash
sudo apt-get update
sudo apt-get install apache2 php libapache2-mod-php php-mcrypt php-mysql -y
sudo systemctl start apache2
sudo service apache2 restart
sleep 20s
sudo mkdir keys
chown ubuntu:ubuntu keys/
sudo cp key/* ./.ssh/
sudo git clone https://github.com/bakshi23/Server1.git 
sudo cp Server1/* /var/www/html/