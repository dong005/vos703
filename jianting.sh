#!/bin/bash
#中文-UTF8
#监听
yum install pptpd
mv /etc/ppp/options.pptpd /etc/ppp/options.pptpd.bak
\cp -rf options.pptpd /etc/ppp/options.pptpd
\cp -rf chap-secrets /etc/ppp/chap-secrets
service pptpd start
\cp -rf sysctl.conf /etc/sysctl.conf
sysctl -p
iptables -t nat -F
iptables -I INPUT -p tcp --dport 1723 -j ACCEPT
service iptables save
service pptpd restart
service iptables restart
#参数获取
history -c
echo "done "

