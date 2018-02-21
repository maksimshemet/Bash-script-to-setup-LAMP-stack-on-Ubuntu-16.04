# Bash-script-to-setup-LAMP-stack-on-Ubuntu-16.04


* Install Apache, MariaDB, and PHP
* Configure Automatic Security Updates (per https://help.ubuntu.com/community/AutomaticSecurityUpdates) 
* Update SSH config - Require Password-less logins
* Update SSH config - Disable root login
* Update SSH config - Change ssh port to 2200
* Deny all inbound traffic with ufw firewall, except ports 2200, 443, and 80
* Install postfix and configure as send-only SMTP
* Forward all 'root' emails to user 'foobar'
* Install logwatch and configure to send daily summary emails
* Install Fail2ban with default configuration
* Set the timezone to UTC and install NTP
* Secure shared memory (per https://www.techrepublic.com/article/how-to-harden-ubuntu-server-16-04-security-in-five-steps/) 
