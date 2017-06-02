#!/usr/bin/env bash

# This apparently fixes something.
sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

# Variables
APPENV=local
DBHOST=localhost
DBNAME=backend
DBUSER=vagrant
DBPASSWD=vagrant

echo -e "\n--- Provisioning now! ---\n"

echo -e "\n--- Updating packages list ---\n"
apt-get update 
echo -e "\n--- Install base packages ---\n"
apt-get -y install curl build-essential python-software-properties git
echo -e "\n--- Adding apt repository and updating again ---\n"
add-apt-repository -y ppa:ondrej/php
apt-get update 

echo -e "\n--- Installing apache2 ---\n"
apt-get -y install apache2

echo -e "\n--- Setting apache2 config ---\n"
rm /etc/apache2/sites-enabled/000-default.conf
touch /etc/apache2/sites-enabled/nosiva.conf
cat << EOF | sudo tee -a /etc/apache2/sites-enabled/nosiva.conf > /dev/null 2>&1
<VirtualHost *:80>
    DocumentRoot /var/www/public
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    <Directory "/var/www/public">
        AllowOverride All
    </Directory>
</VirtualHost>
EOF

echo -e "\n--- Enabling apache2 mod_rewrite ---\n"
a2enmod rewrite

echo -e "\n--- Installing php5 ---\n"
apt-get -y install -y wget git php5.6 php5.6-mcrypt php5.6-mysql php5.6-xml
echo -e "\n--- Restarting apache2 ---\n"
/etc/init.d/apache2 restart

echo -e "\n--- Installing composer globally ---\n"
curl -sS https://getcomposer.org/installer | php 
mv composer.phar /usr/local/bin/composer

echo -e "\n--- Install MySQL specific packages and settings ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
apt-get -y install mysql-server

echo -e "\n--- Setting MySQL default engine to MyISAM ---\n"
cat << EOF | sudo tee -a /etc/mysql/conf.d/default_engine.cnf
[mysqld]
default-storage-engine = MyISAM
EOF

echo -e "\n--- Making MySQL accessible from the outside ---\n"
replace "127.0.0.1" "0.0.0.0" -- /etc/mysql/my.cnf
sudo service mysql restart

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'%' identified by '$DBPASSWD'"

# This is the default folder shipped with the box, we remove it so it doesn't end up in our repository
rm -rf /var/www/html

echo -e "\n--- Switching to refactoring branch and installing composer dependencies ---\n"
echo -e "\n--- This might take a while dependning on the number of dependencies... ---\n"
cd /var/www
composer install 

#echo -e "\n--- Migrating and seeding database ---\n"
#php /var/www/artisan migrate > /dev/null 2>&1
#php /var/www/artisan db:seed > /dev/null 2>&1