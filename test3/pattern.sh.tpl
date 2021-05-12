#!/bin/bash
sudo yum update -y
sudo yum install vim mc curl httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
ip=$(curl -s  http://169.254.169.254/latest/meta-data/public-ipv4)

sudo echo "<h1>${name1} ${name2} we are greeting you from ip <div style="color:red">$ip</div></h1>" > /var/www/html/index.html
sudo echo " <br>
%{ for word in mylist ~}
${word}
%{ endfor ~}
!!!!
<br> <b>The first element in the list is ${mylist[0]}</b>
" >> /var/www/html/index.html