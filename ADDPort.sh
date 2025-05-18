#!/bin/sh
service iptables reload
iptables -A INPUT -p udp -m udp --dport 9060 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 8060 -j ACCEPT
/etc/init.d/iptables save
\cp -f /etc/sysconfig/iptables /etc/sysconfig/iptablesbak