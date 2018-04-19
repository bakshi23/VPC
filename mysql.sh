#!/bin/bash
mysql_pass=sqlpass123
export DEBIAN_webserver=noninteractive
debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password password '$mysql_pass''
debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password_again password '$mysql_pass''
apt-get -y install mysql-server
#Configure Password and Settings for Remote Access
cp /etc/mysql/my.cnf /etc/mysql/my.bak.cnf
ip=`ifconfig eth0 | grep "inet addr"| cut -d ":" -f2 | cut -d " " -f1` ; sed -i "s/\(bind-address[\t ]*\)=.*/\1= $ip/" /etc/mysql/my.cnf
mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('"$mysql_pass"') WHERE User='root'; FLUSH PRIVILEGES;"
sleep 10s
mysql -u root -p$mysql_pass -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '"$mysql_pass"'; FLUSH PRIVILEGES;"
#Restart
service mysql restart
echo "MySQL Installation and Configuration is Complete."
mysql -u root -psqlpass123 -D mysql -e "CREATE TABLE test (id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,firstname VARCHAR(30) NOT NULL,lastname VARCHAR(30) NOT NULL,email VARCHAR(50),reg_date TIMESTAMP);"
mysql -u root -psqlpass123 -D mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%mydatabase.demo.abc' IDENTIFIED BY 'sqlpass123' WITH GRANT OPTION;"
git clone https://github.com/bakshi23/db.git
sudo mv db/* etc/mysql/mysql.conf.d/
/usr/bin/mysqladmin -u root -pmymysqlpass proc
	