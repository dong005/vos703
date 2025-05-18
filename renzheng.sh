#!/bin/bash
#中文-UTF8
sync
ll
yum clean all
yum makecache
yum install -y php http
service httpd restart
sed -i "s/Listen 80/Listen 9090/" /etc/httpd/conf/httpd.conf
\cp -rf zhou.jpg zhou.png index.php /var/www/html/
ls
chmod 777 /var/www/html/
\cp -rf iptables /etc/sysconfig/iptables
chmod 644 /etc/sysconfig/iptables
service iptables restart
iptables -nvL
service httpd restart
ip a
\cp -rf sudoers /etc/sudoers
chmod 644 /etc/sudoers
service iptables restart
service httpd restart
chkconfig httpd on
chkconfig iptables on
\cp -rf MbxWatch.sh /opt/MbxWatch.sh
chmod 777 /opt/MbxWatch.sh
\cp -rf cache.sh /opt/cache.sh
chmod 777 /opt/cache.sh
yum -y install vixie-cron
chkconfig --level 345 crond on
echo -e "01 01 * * * /etc/init.d/iptables restart" >> /var/spool/cron/root
echo -e "*/1 * * * * /opt/MbxWatch.sh" >> /var/spool/cron/root
echo -e "*/30 * * * * /opt/cache.sh" >> /var/spool/cron/root
service crond reload
service crond restart
cd
rm -rf *
reboot
echo "done "