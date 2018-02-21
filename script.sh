#!/bin/bash

function apache2Install {
	apt-get install -y apache2 libapache2-mod-php7.0
	a2enmod php7.0
	systemctl enable apache2
	service apache2 start
}

function mariadbInstall {
	rm -rf /var/lib/mysql
	apt-get -y  install software-properties-common
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
	add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.utexas.edu/mariadb/repo/10.2/ubuntu xenial main'
	DEBIAN_FRONTEND=noninteractive apt-get install -y   mariadb-server mariadb-client
	mysqld_safe --skip-grant-tables &
	mysql -u root -e "update mysql.user set plugin='mysql_native_password';"
	mysql -u root -e "flush privileges;"
	kill -9 $(pgrep mysql)
	systemctl enable mysql
	service mysql  start
}

function phpInstall {
	apt-get -y install php7.0 php7.0-mysql php7.0-curl php7.0-gd php7.0-intl php-pear php-imagick \
		php7.0-imap php7.0-mcrypt php-memcache  php7.0-pspell php7.0-recode php7.0-sqlite3 \
		php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-mbstring php-gettext
}

function configAutoUpdate {
	apt-get install -y unattended-upgrades
	printf "APT::PeriodiPeriodic::Download-Upgradeable-Packages "1"; \nAPT::Periodic::AutocleanInterval "7"; \nAPT::Periodic::Unattended-Upgrade "1";" > /etc/apt/apt.conf.d/20auto-upgrades 
	printf 'Unattended-Upgrade::Allowed-Origins {
         "${distro_id}:${distro_codename}";
         "${distro_id}:${distro_codename}-security";
 //      "${distro_id}:${distro_codename}-updates";
 //      "${distro_id}:${distro_codename}-proposed";
 //      "${distro_id}:${distro_codename}-backports";
 };' > /etc/apt/apt.conf.d/50unattended-upgrades

}

function sshd_conf {
	sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
	sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
	sed -i -e 's/Port 22/Port 2200/' /etc/ssh/sshd_config
	service sshd restart
}

function postfixInstall {
	DEBIAN_FRONTEND=noninteractive apt-get install -y postfix
	sed -i -e 's/inet_interfaces = loopback-only/inet_interfaces = all/' /etc/postfix/main.cf
	printf "# See man 5 aliases for format
postmaster:    root
root:          foobar" > /etc/aliases
	newaliases
	systemctl enable postfix
	service postfix start
}

function logWatch {
	apt-get install -y logwatch libdate-manip-perl
	logwatch --mailto root@localhost --output mail --format html --range 'between -1 days and today'
}

function f2bInst {
	apt-get install -y fail2ban
}

function timez {
	timedatectl set-timezone UTC
	apt-get install -y ntp
	systemctl enable ntp
	service ntp start
}

function secConf {
	echo "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" >> /etc/fstab
	sed -i -e "s/session optional pam_motd.so noupdate/#session optional pam_motd.so noupdate/" /etc/pam.d/sshd
	printf "# IP Spoofing protection
	net.ipv4.conf.all.rp_filter = 1
	net.ipv4.conf.default.rp_filter = 1
	
	# Disable source packet routing
	net.ipv4.conf.all.accept_source_route = 0
	net.ipv6.conf.all.accept_source_route = 0
	net.ipv4.conf.default.accept_source_route = 0
	net.ipv6.conf.default.accept_source_route = 0
	
	# Ignore send redirects
	net.ipv4.conf.all.send_redirects = 0
	net.ipv4.conf.default.send_redirects = 0
	
	# Log Martians
	net.ipv4.conf.all.log_martians = 1
	
	# Ignore ICMP redirects
	net.ipv4.conf.all.accept_redirects = 0
	net.ipv6.conf.all.accept_redirects = 0
	net.ipv4.conf.default.accept_redirects = 0
	net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
	sysctl -p
	printf '# The "order" line is only used by old versions of the C library.
	order bind,hosts
	nospoof on' > /etc/host.conf
}

function ufwConf {
	apt-get install -y ufw
	ufw default deny incoming
	ufw allow  80
	ufw allow  443
	ufw allow  2200
	ufw --force enable
}

function resmysql {
#to work properly mysql needs to be restarted after all installations
	service mysql restart
	mysqladmin -u root password rootpassword
}

#useradd foobar

apt-get update

phpInstall
apache2Install
mariadbInstall
postfixInstall
configAutoUpdate
ufwConf
sshd_conf
logWatch
f2bInst
timez
secConf
resmysql
