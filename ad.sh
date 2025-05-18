#!/bin/bash
#中文-UTF8
chmod 777 *
rm -rf /etc/yum.repos.d/*
sed -i "s|enabled=1|enabled=0|g" /etc/yum/pluginconf.d/fastestmirror.conf
curl -o /etc/yum.repos.d/CentOS-Base.repo https://www.xmpan.com/Centos-6-Vault-Aliyun.repo
yum clean all && yum makecache
yum install wget
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
service iptables stop
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
# if  [ "$uname" != "2.6.32-358.el6.x86_64" ];then
# 	yum remove -y kernel kernel-firmware
# 	rpm -ivh kernel-firmware-2.6.32-358.el6.noarch.rpm
# 	rpm -ivh kernel-2.6.32-358.el6.x86_64.rpm
# 	reboot
# fi
yum remove -y perl perl-DBI mysql mysql-* 
yum remove -y perl perl-DBI mysql mysql-* 
sh create_user_kunshi.sh
sh create_user_kunshiweb.sh
yum install -y perl-DBI-1.40-5.i386.rpm
rpm -ivh MySQL-server-community-5.0.96-1.rhel5.x86_64.rpm --nodeps --force
rpm -ivh MySQL-client-community-5.0.96-1.rhel5.x86_64.rpm --nodeps --force
cp -rf my.cnf /etc/my.cnf
chmod 644 /etc/my.cnf
service mysql restart
rpm -ivh jdk-6u45-linux-amd64.rpm
tar zxvf apache-tomcat-7.0.23.tar.gz
mv apache-tomcat-7.0.23 /home/kunshiweb/base/apache-tomcat
tar -zxvf jrockit-jdk1.6.0_33-R28.2.4-4.1.0.tar.gz
cp -rf ./jrockit-jdk1.6.0_33-R28.2.4-4.1.0/ /home/kunshi/base/jdk_default
cp -rf ./jrockit-jdk1.6.0_33-R28.2.4-4.1.0/ /home/kunshiweb/base/jdk_default
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
head -2 /home/kunshi/vos3000/etc/server.conf | tail -1