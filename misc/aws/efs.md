# How to use EFS

## Create EFS File System (Select your VPC and Regional)
Create Security Group and allow inbound connections on port 2049 from within VPC IP range / CIDR
Create EFS while choosing your VPC.  Select regional

## Launch Webserver ONE (EC2) and mount EFS
sudo -i 
yum install httpd amazon-efs-utils -y
mount -t efs -o tls <fs-id>:/ /var/www/html
cd /var/www/html
echo "EFS Test page" > index.html
chmod -R 755 wp-content
chown -R apache:apache wp-content
systemctl enable httpd 
systemctl start httpd

## Launch Webserver TWO (EC2) and mount EFS
sudo -i
yum install httpd amazon-efs-utils -y 
mount -t efs -o tls <fs-id>:/ /var/www/html
systemctl enable httpd
systemctl start httpd

## Verify that server is running and content is synced automatically from EFS