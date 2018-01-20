#!/bin/bash
echo "Ubuntu 16.04 Web servar installation"
echo "Nginx"
echo "MariaDB"
echo "PHP 7.2"
echo "Git,Composer,NodeJS,Gulp,Bower"

echo "First install update"
sudo apt-get update

read -p "Are you sure(y/n)" YES

if [$YES]; then

	echo "Note: Script assumes you have a file named nginx-site in script directory to be copied to /etc/nginx/sites-available"
	read -p "Install Nginx? (y/n)" NGINX

	if[ $NGINX = 'y' ]; then
		sudo apt-get install -y nginx
		sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
		echo "Moveing default site file to /etc/nginx/sites-available/drfaul.bak"
		sudo cp nginx-site /etc/nginx/sites-available/myapp
		read -p "Would you like to modify nginx config (y/n)" MOD
		if [ $MOD = 'y' ]; then
			sudo nano /etc/nginx/sites-available/myapp
		fi
		sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-available/
		sudo nginx -t
		sudo service nginx reload
		sudo service nginx restart
		read -p "Install OpenSSL & Generate SSl for Nginx? (y/n)" SSL
		if [ $SSL = 'y' ]; then
			sudo apt-get install -y openssl
			sudo mkdir /etc/nginx/ssl
			sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
			sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
			sudo service nginx restart
		fi
	fi
	read -p "Install PHP7.2? (y/n)" PHP
	if [ $PHP = 'y']; then
		sudo apt install python-software-properties
		sudo apt add-apt-repository ppa:ondrej/php
		sudo apt update
		sudo apt install -y php7.2 php7.2-fpm php7.2-cli php7.2-mcrypt php7.2-mbstring php7.2-mysql
		sudo echo 'cgi.fix_pathinfo=0' >> /etc/php/7.2/fpm/php.ini
		echo 'Adding cgi.fix_pathinfo=0 to /etc/php/7.2/fpm/php.ini'
		read -p "Do you want edit php.ini (y/n)" INI
		if [ $INI = 'y' ]; then
			sudo nano /etc/php/7.2/fpm/php.ini
		fi
		sudo service php7.2-fpm restart
	fi
	read -p "Install MariaDB? (y/n)" MARIADB 
	if [ $MARIADB = 'y' ]; then
		sudo apt install -y mariadb-server mariadb-client
		sudo mysql_secure_installation
		sudo mysql << EOF
		use mysql;
		update user set plugin=`` where User=`root`;
		flush privileges;
		exit
EOF
	fi

	read -p "Install Curl, Git and composer? (y,n)" CGC
	if [ $CGC = 'y' ]; then
		sudo apt-get install curl git
		curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
	fi
	read -p "Install Node.js v 6.x? (y/n)" NODE
	if [ $NODE = 'y' ]; then
	 	curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
	 	sudo apt-get install -y nodejs
	fi
	read -p "Install bower and gulp? (y/n)" IBG
	if [ $IBG = 'y' ]; then
		sudo npm install -g bower
		sudo npm install -g gulp-cli
	fi

else
	exit
fi

