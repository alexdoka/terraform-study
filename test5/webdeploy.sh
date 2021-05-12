#! /bin/bash
sudo yum update -y
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install httpd -y
sudo yum install stress -y
sudo systemctl enable httpd
sudo systemctl start httpd
ip=`curl -s https://2ip.ru`
sudo echo "<h2>Hello from $ip</h2>" > /var/www/html/index.html