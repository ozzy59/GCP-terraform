#!/bin/bash
apt update 
apt -y install apache2
echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html
systemctl start apache2
systemctl enable apache2