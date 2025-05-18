#!/bin/sh
service iptables reload
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
/etc/init.d/iptables save
\cp -f /etc/sysconfig/iptables /etc/sysconfig/iptablesbak