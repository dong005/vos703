#!/bin/bash
#中文-UTF8
cd 
cd /etc/yum.repos.d
rm -fr *
cd 
\cp -rf CentOS-Base*.repo /etc/yum.repos.d/CentOS-Base.repo
yum clean all && yum makecache
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
service iptables stop
#yum install -y zip
yum install ntp crontabs -y
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
service ntpd stop
ntpdate cn.ntp.org.cn
free=$(free -m|awk '{print $2}'|tail -1)
if  [[ "$free" < "1024" ]];then
echo "making swap..."
dd if=/dev/zero of=/mnt/swapfile bs=1M count=8192
mkswap /mnt/swapfile
swapon /mnt/swapfile
echo "set chkconfig"
echo "/mnt/swapfile          /swap                   swap    defaults        0 0" >> /etc/fstab
fi
uname=$(uname -a|awk '{print $3}')
if  [ "$uname" != "2.6.32-358.el6.x86_64" ];then
	yum remove -y kernel kernel-firmware
	yum install -y kernel-2.6.32-358.el6.x86_64.rpm kernel-firmware-2.6.32-358.el6.noarch.rpm
	reboot
fi
#chmod 777 *
yum remove -y perl perl-DBI mysql mysql-* 
yum remove -y perl perl-DBI mysql mysql-* 
sh create_user_kunshi.sh
sh create_user_kunshiweb.sh
yum install -y perl-DBI-1.40-5.i386.rpm
rpm -ivh MySQL-server-community-5.0.96-1.rhel5.x86_64.rpm --nodeps --force
rpm -ivh MySQL-client-community-5.0.96-1.rhel5.x86_64.rpm --nodeps --force
\cp -rf my.cnf /etc/my.cnf
chmod 644 /etc/my.cnf
service mysql restart
rpm -ivh jdk-6u45-linux-amd64.rpm
tar zxvf apache-tomcat-7.0.23.tar.gz
mv apache-tomcat-7.0.23 /home/kunshiweb/base/apache-tomcat
tar -zxvf jrockit-jdk1.6.0_33-R28.2.4-4.1.0.tar.gz
\cp -rf ./jrockit-jdk1.6.0_33-R28.2.4-4.1.0/ /home/kunshi/base/jdk_default
\cp -rf ./jrockit-jdk1.6.0_33-R28.2.4-4.1.0/ /home/kunshiweb/base/jdk_default
rpm -ivh emp-2.1.6-00.noarch.rpm
rpm -ivh vos3000-2.1.6-00.i586.rpm
rpm -ivh vos3000-web-2.1.6-00.i586.rpm
rpm -ivh vos3000-webdata-2.1.6-00.i586.rpm
rpm -ivh vos3000-webexternal-2.1.6-00.i586.rpm
rpm -ivh vos3000-webthirdparty-2.1.6-00.i586.rpm
rpm -ivh vos3000-webserver-2.1.6-00.i586.rpm
rpm -ivh mbx3000-2.1.6-00.i586.rpm
rpm -ivh mgc-2.1.6-00.i586.rpm
rpm -ivh servermonitor-2.1.6-00.i586.rpm
rpm -ivh callservice-2.1.6-00.i586.rpm
rpm -ivh dial-2.1.6-00.i586.rpm
rpm -ivh valueadded-2.1.6-00.i586.rpm
chmod 644 /etc/my.cnf
mkdir /home/kunshi/license
#./vos30002160YZ.bin
#ip add
#head -2 /home/kunshi/vos3000/etc/server.conf | tail -1
#cd ..
#cd 6.0
#认证防护
#sync
#yum clean all
#yum makecache
#yum install -y php http
#service httpd restart
#sed -i "s/Listen 80/Listen 52088/" /etc/httpd/conf/httpd.conf
#\cp -rf rz.png index.php /var/www/html/
#ls
#chmod 777 /var/www/html/
#\cp -rf iptables /etc/sysconfig/iptables
#chmod 644 /etc/sysconfig/iptables
#service iptables restart
#iptables -nvL
#service httpd restart
#ip a
#\cp -rf sudoers /etc/sudoers
##chmod 644 /etc/sudoers
#service iptables restart
#service httpd restart
#chkconfig httpd on
#chkconfig iptables on
#chmod 777 /opt/MbxWatch.sh
#\cp -rf cache.sh /opt/cache.sh
#chmod 777 /opt/cache.sh
#\cp -rf jiankong.sh /opt/jiankong.sh
#chmod 777 /opt/jiankong.sh
#\cp -rf liuliang.sh /opt/liuliang.sh
#chmod 777 /opt/liuliang.sh
#yum -y install vixie-cron
#yum install crontab
#chkconfig --level 345 crond on
#\cp -rf install7.sh /home
#\cp -rf mainland.sh /root
#\cp -rf mainland.sh /home/mainland.sh
#cd /home
#chmod 777 *
#\cp -rf install8.sh /etc/rc.d/init.d/install8.sh
#chmod +x /etc/rc.d/init.d/install8.sh
#chmod +x /etc/rc.d/rc.local
#修改8080
#sed -i -e 's|8080|9090|' /home/kunshiweb/base/apache-tomcat/conf/server.xml
#sed -i "s/#Port 22/Port 60022/" /etc/ssh/sshd_config
#service sshd restart
#cd
#cd /etc/rc.d/init.d
#chkconfig --add install8.sh
#chkconfig install8.sh on
#国内防火墙ip
#yum install ipset
#ipset create mainland hash:net maxelem 65536
#\cp -rf mainland.sh /home/mainland.sh
#chmod +x /home/mainland.sh
#cd 
#cd /home
#chmod 777 *
#./mainland.sh
#定时任务
#echo -e "01 01 * * * /etc/init.d/iptables restart" >> /var/spool/cron/root
#echo -e "*/30 * * * * /opt/cache.sh" >> /var/spool/cron/root
#echo -e "0 0 1 ? * L /home/mainland.sh" >> /var/spool/cron/root
#echo -e "/home/mainland.sh" >> /etc/rc.d/rc.local
#echo -e "/etc/rc.d/init.d/install8.sh" >> /etc/rc.d/rc.local
#echo -e "0 0 * * * /home/mainland.sh" >> /var/spool/cron/root
#service crond reload
#service crond restart
#认证
#chkconfig iptables on
#yum install php httpd  -y
#service httpd restart
#chkconfig httpd on
#iptables -F
#iptables -P INPUT DROP
#iptables -P OUTPUT ACCEPT
#iptables -A INPUT -i lo -j ACCEPT
#iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
#iptables -I INPUT -s 58.212.0.0/16 -j DROP
#iptables -I INPUT -s 222.45.0.0/16 -j DROP
#iptables -I INPUT -s 222.95.0.0/16 -j DROP
#iptables -I INPUT -s 115.29.234.201 -j DROP
#iptables -A INPUT -p tcp -m tcp --dport 61888 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 52088 -j ACCEPT
#iptables -t nat -A PREROUTING -p tcp --dport 61888 -j REDIRECT --to-port 8080
#iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 1719 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 1720 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 3719 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 3720 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 10000:49999 -j ACCEPT
#iptables -A INPUT -p udp -m udp --dport 5060 -j ACCEPT
#iptables -A INPUT -m set --match-set mainland src -p udp --dport 5060 -j ACCEPT
#iptables -A INPUT -p udp -m udp --dport 6060 -j ACCEPT
#iptables -A INPUT -p udp -m udp --dport 5070 -j ACCEPT
#iptables -A INPUT -p udp -m udp --dport 5033 -j ACCEPT
#iptables -A INPUT -p udp -m udp --dport 5034 -j ACCEPT
#iptables -A INPUT -p udp -m udp --dport 10000:49999 -j ACCEPT
#/etc/init.d/iptables save
#rm -rf /var/www/html/* >/dev/null 2&>1
#cp -p www/* /var/www/html
#setenforce 0
#chmod 777 /var/www/html/*
#chmod u+s /var/www/html/run
##sed -i -e 's|Listen 80|Listen 52088|' /etc/httpd/conf/httpd.conf
#service httpd restart
#service iptables restart
#cd
#cd 6.0
#\cp -rf install7.sh /home
#\cp -rf mainland.sh /root
#\cp -rf mainland.sh /home/mainland.sh
#chmod +x /etc/rc.d/rc.local
#国内防火墙ip
#yum install ipset
#ipset create mainland hash:net maxelem 65536
#\cp -rf mainland.sh /home/mainland.sh
#chmod +x /home/mainland.sh
#cd 
#cd /home
#chmod 777 *
#./mainland.sh
#定时任务
#yum -y install vixie-cron
#yum install crontab
#chkconfig --level 345 crond on
#echo -e "01 01 * * * /etc/init.d/iptables restart" >> /var/spool/cron/root
#echo -e "0 0 1 ? * L /home/mainland.sh" >> /var/spool/cron/root
#echo -e "/home/mainland.sh" >> /etc/rc.d/rc.local
#service crond reload
#service crond restart
#参数获取
#./vos30002160ZM.bin
#ip add
cd
chmod 777 vossafe-centos6.bin
./vossafe-centos6.bin
\cp -rf MbxWatch.sh /opt/MbxWatch.sh
echo -e "*/1 * * * * /opt/MbxWatch.sh" >> /var/spool/cron/root
mv -f /usr/bin/xxwget /usr/bin/wget
cd
wget yum.songshi.co/bin/vos30002160YZ.bin
mv -f /usr/bin/wget /usr/bin/xxwget
chmod 777 *
./vos30002160YZ.bin
HIP=$(ip a|grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|grep -v "127"|awk '{print $2}')
echo -e $HIP >> HIP
HIP=$(sed s/[[:space:]]/,/g HIP)
ifconfig=$(ifconfig -a | awk '{print $5}')
echo -e "$ifconfig\n" >> ifconfig
sed -i 's/:/-/g' ifconfig
MAC=$(head -1 ifconfig | tail -1)
rpm=$(/bin/rpm --qf %{INSTALLTIME} -q rpm)
vos3000=$(/bin/rpm --qf %{INSTALLTIME} -q vos3000)
jdk=$(/bin/rpm --qf %{INSTALLTIME} -q jdk)
echo -e "\033[31m$HIP $MAC $rpm $vos3000 $jdk\033[0m"
#ifconfig
#cd
#cd 6.0fh
#./vos30002160YZ.bin
#head -2 /home/kunshi/vos3000/etc/server.conf | tail -1
#echo "VOSFH,Done! "
echo "游览器认证:ip:5101, 认证密码:shenz521, 登录账号密码:admin, sip端口:62019,62019"
head -2 /home/kunshi/vos3000/etc/server.conf | tail -1
cd
rm -rf * #6.0fh.zip #6.0.fh install.sh
history -c
echo "done"

