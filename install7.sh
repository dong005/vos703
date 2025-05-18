#!/bin/bash
#中文-UTF8
#国内防火墙ip
yum install ipset
ipset create mainland hash:net maxelem 65536
#\cp -rf mainland.sh /home/mainland.sh
chmod +x /home/mainland.sh
cd 
cd /home
chmod 777 *
./mainland.sh
service iptables restart
#定时任务
#echo -e "0 0 * * * /home/mainland.sh" >> /var/spool/cron/root
#修改8080
#\cp -rf server.xml /home/kunshiweb/base/apache-tomcat/conf/server.xml
#cd /home/kunshiweb/base/apache-tomcat/bin
#./shutdown.sh
#./startup.sh
#参数获取
echo "done "

