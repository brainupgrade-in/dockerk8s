# EC2 User Data
## Docker
#!/bin/bash
yum install -y docker
systemctl enable docker
systemctl start docker

## HTTPD
#!/bin/bash
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
cd /var/www/html
echo "<html><body><h1>Welcome to Cloud - Bootcamp </h1></body></html>" > index.html

## Wordpress
#!/bin/bash
yum install -y
yum install httpd php php-mysql -y
cd /var/www/html
echo "healthy" > healthy.html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html
rm -rf wordpress
rm -rf latest.tar.gz
chmod -R 755 wp-content
chow -R apache:apache wp-content
chkconfig http on
service httpd start

## Instance Metadata
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)
INTERFACE=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
SUBNETID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${INTERFACE}/subnet-id)
echo "<center><h1>Instance subnet ID: ${SUBNETID} </h1></center>" > /var/www/html/index.txt
echo "<center><h1>Instance hostname: ${HOSTNAME} </h1></center>" >> /var/www/html/index.txt
cp /var/www/html/index.txt /var/www/html/index.html