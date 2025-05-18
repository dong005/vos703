#!/bin/bash
 
#获取cpu使用率
cpuUsage=`top -n 1 | awk -F '[ %]+' 'NR==3 {print $2}'`
#获取磁盘使用率
data_name="/dev/vda1"
diskUsage=`df -h | grep $data_name | awk -F '[ %]+' '{print $5}'`
logFile=/tmp/monitor.log
#获取内存情况
mem_total=`free -m | awk -F '[ :]+' 'NR==2{print $2}'`
mem_used=`free -m | awk -F '[ :]+' 'NR==3{print $3}'`
#统计内存使用率
mem_used_persent=`awk 'BEGIN{printf "%.0f\n",('$mem_used'/'$mem_total')*100}'`
#获取报警时间
now_time=`date '+%F %T'`
function send_mail(){
        mail -s "服务器监控报警" 495563639@qq.com < /tmp/monitor.log
}
function check(){
        if [[ "$cpuUsage" > 80 ]] || [[ "$diskUsage" > 80 ]] || [[ "$mem_used_persent" > 95 ]];then
                echo "报警时间：${now_time}" > $logFile
                echo "CPU使用率：${cpuUsage}% --> 磁盘使用率：${diskUsage}% --> 内存使用率：${mem_used_persent}%" >> $logFile
                send_mail
        fi
}
function main(){
        check
}
main