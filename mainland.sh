#!/usr/bin/env bash
ipset create mainland hash:net maxelem 65536
wget --no-check-certificate -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /home/mainland.txt
ipset flush mainland
while read ip; do
    ipset add mainland $ip
done < /home/mainland.txt
ipset save chnroute > /home/mainland.conf
#重启
service iptables restart
echo "done "
