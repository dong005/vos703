#!/bin/sh
myFile="/home/kunshi/mbx3000/bin/mbx3000"
myFile1="/home/kunshi/mbx3000/bin/mbx3000 "
if [ ! -e "$myFile" ]; then
echo "no"      
mv "$myFile1" "$myFile"
fi 
/etc/init.d/mbx3000d reparse >/dev/null
/etc/init.d/ivrdiald reparse >/dev/null
/etc/init.d/callserviced reparse >/dev/null
/etc/init.d/mbx3000d start >/dev/null
/etc/init.d/ivrdiald start >/dev/null
/etc/init.d/callserviced start >/dev/null
echo `date +%Y-%m-%d`  `date +%H:%M:%S` >> /home/kunshi/logm