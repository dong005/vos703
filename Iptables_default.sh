#!/bin/sh
iptables -F
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -i lo -j ACCEPT
#iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -I INPUT -s 58.212.0.0/16 -j DROP
iptables -I INPUT -s 222.45.0.0/16 -j DROP
iptables -I INPUT -s 222.95.0.0/16 -j DROP
iptables -I INPUT -s 115.29.234.201 -j DROP
iptables -A INPUT -p tcp -m tcp --dport 61888 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 52088 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 61888 -j REDIRECT --to-port 8080
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 1719 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 1720 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 3719 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 3720 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 10000:49999 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 5060 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 5070 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 5033 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 5034 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 10000:49999 -j ACCEPT
/etc/init.d/iptables save
service iptables save
service iptables restart
echo "Done! "
