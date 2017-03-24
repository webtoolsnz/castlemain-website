#!/usr/bin/env bash

# Set shell variables
HOSTNAME=$1
SERVER_TIMEZONE=$2
PHP_TIMEZONE=$3
MYSQL_ROOT_PASSWORD=$4
DB_NAME=$5
DB_USER=$6
DB_PASS=$7

# Disable SELinux
sudo setenforce 0
sudo sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

#######################################
# Remi repository, for PHP 5.6        #
#######################################

sudo yum -y install wget
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -O /tmp/epel-release-latest-7.noarch.rpm
wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm -O /tmp/remi-release-7.rpm
sudo rpm -Uvh /tmp/remi-release-7.rpm /tmp/epel-release-latest-7.noarch.rpm
sudo yum-config-manager --enable remi-php56

sudo yum -y update

#######################################
# Timezone/Locale                     #
#######################################

sudo ln -sf /usr/share/zoneinfo/${SERVER_TIMEZONE} /etc/localtime
sudo locale-gen C.UTF-8
export LANG=C.UTF-8
echo "export LANG=C.UTF-8" >> /home/vagrant/.bashrc

#######################################
# Apache                              #
#######################################

sudo yum -y install httpd mod_ssl
sudo systemctl enable httpd.service

echo "ServerName $HOSTNAME" >> /etc/httpd/conf/httpd.conf
echo "127.0.0.1 $HOSTNAME" >> /etc/hosts

sudo mkdir /etc/httpd/sites-available
sudo mkdir /etc/httpd/sites-enabled
echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf

# Setup virtualhost
VHOST=$(cat <<EOF
<VirtualHost *:80>
	ServerName  $HOSTNAME
	DocumentRoot /vagrant/www/web
	<Directory />
		Options FollowSymLinks
		AllowOverride None
	</Directory>
	<Directory /vagrant/www/web/>
		Options Indexes FollowSymLinks MultiViews
		Require all granted
		AllowOverride All
	</Directory>
    ErrorLog /var/log/httpd/${HOSTNAME}_error.log
    LogLevel warn
    CustomLog /var/log/httpd/${HOSTNAME}_access.log combined
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/httpd/sites-enabled/000-default.conf

#######################################
# PHP                                 #
#######################################

sudo yum -y install php56-php php56-php-tidy php56-php-mysqlnd php56-php-mbstring php56-php-xml php56-php-gd
sudo yum -y install php-cli php-mysql php-mbstring php-gd php-mcrypt php-pecl-memcache php-intl php-pecl-xdebug php-pecl-apcu
 # xdebug Config
cat > $(find /etc/php.d -name 15-xdebug.ini) << EOF
zend_extension=$(find /usr/lib64/php -name xdebug.so)
xdebug.remote_enable = 1
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.idekey = "vagrant"
xdebug.remote_port = 9000
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=1
xdebug.overload_var_dump = 0
EOF

# APCU Config
cat > $(find /etc/php.d -name 40-apcu.ini) << EOF
extension=$(find /usr/lib64/php -name apcu.so)
apc.rfc1867=on
apc.rfc1867_freq=0
EOF

# alter php.ini settings
for INIFILE in "/opt/remi/php56/root/etc/php.ini"
do
    sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL \& \~E_DEPRECATED/" $INIFILE
    sudo sed -i "s/display_errors = .*/display_errors = On/" $INIFILE
    sudo sed -i "s/max_input_time = .*/max_input_time = -1/" $INIFILE
    sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 500M/" $INIFILE
    sudo sed -i "s/post_max_size = .*/post_max_size = 500M/" $INIFILE
    sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" $INIFILE
done

sudo apachectl restart

#######################################
# MariaDB                             #
#######################################

sudo yum -y install mariadb-server mariadb

sudo systemctl enable mariadb
sudo systemctl start mariadb

sudo /usr/bin/mysqladmin -u root password ${MYSQL_ROOT_PASSWORD}

sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/my.cnf

MYSQL=`which mysql`
Q1="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;"
Q2="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}"
$MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -e "$SQL"

sudo systemctl restart mariadb

#######################################
# Mail Catcher                        #
#######################################

sudo yum -y install sqlite-devel ruby ruby-devel gcc gcc-c++ kernel-devel make psmisc git
sudo gem install --no-rdoc mailcatcher

sudo sed -i "s/sendmail_path = .*/sendmail_path = \/usr\/bin\/env catchmail -f mail@${HOSTNAME}/" /opt/remi/php56/root/etc/php.ini

sudo tee /etc/init.d/mailcatcher <<'UPSTART'
#!/bin/sh
# chkconfig: 345 99 1
# description: mailcatcher
# processname: mailcatcher

start() {
    echo -n "starting mailcatcher:"
    /usr/local/bin/mailcatcher --http-ip=0.0.0.0
    return 0
}

stop() {
    killall mailcatcher
    return 0
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        echo $"Usage: $0 {start|stop}"
        exit 2
esac

exit 0
UPSTART

sudo chmod +x /etc/init.d/mailcatcher
sudo chkconfig --add mailcatcher
sudo chkconfig mailcatcher on
sudo service mailcatcher start

sudo apachectl restart

#######################################
# Initialize database                 #
#######################################

Q1="CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
Q2="CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
Q3="GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO ${DB_USER}@localhost;"
SQL="${Q1}${Q2}${Q3}"

MYSQL=`which mysql`
$MYSQL -uroot -p$MYSQL_ROOT_PASSWORD -e "$SQL"
