#！/usr/bin/expect
#检查版本
cat /etc/redhat-release
#检查内核
cat /etc/issue && echo $HOSTTYPE && uname -r
ping www.baidu.com
echo "done "

