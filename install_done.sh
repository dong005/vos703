#!/bin/bash
#中文-UTF8
# vos3000 服务端+客户端+web端完整安装脚本
# 去除防火墙相关内容，专注于核心功能安装

# 1. 系统环境准备
echo "正在准备系统环境..."
chmod 777 *
rm -rf /etc/yum.repos.d/*
sed -i "s|enabled=1|enabled=0|g" /etc/yum/pluginconf.d/fastestmirror.conf
curl -o /etc/yum.repos.d/CentOS-Base.repo https://www.xmpan.com/Centos-6-Vault-Aliyun.repo
yum clean all && yum makecache
yum install wget -y

# 2. 关闭SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# 3. 设置时区和时间同步
yum install ntp crontabs -y
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
service ntpd stop
ntpdate cn.ntp.org.cn

# 4. 内存检查与SWAP设置
free=$(free -m|awk '{print $2}'|tail -1)
if [[ "$free" < "1024" ]]; then
    echo "内存不足，创建swap分区..."
    dd if=/dev/zero of=/mnt/swapfile bs=1M count=8192
    mkswap /mnt/swapfile
    swapon /mnt/swapfile
    echo "/mnt/swapfile          /swap                   swap    defaults        0 0" >> /etc/fstab
fi

# 5. 内核检查与安装

# 显示当前内核版本信息
echo "当前内核版本信息:"
uname -r
echo "已安装的内核列表:"
rpm -q kernel

# 检查是否需要安装指定内核
if ! rpm -q kernel | grep -q "2.6.32-358.el6.x86_64"; then
    echo "未找到指定内核，开始安装 2.6.32-358.el6.x86_64 内核..."
    
    # 安装内核前先备份 grub 配置
    if [ -f "/boot/grub/grub.conf" ]; then
        cp /boot/grub/grub.conf /boot/grub/grub.conf.bak
    fi
    
    # 安装指定内核
    echo "安装内核包..."
    rpm -ivh kernel-firmware-2.6.32-358.el6.noarch.rpm --nodeps --force
    rpm -ivh kernel-2.6.32-358.el6.x86_64.rpm --nodeps --force
    
    # 检查内核是否安装成功
    if ! rpm -q kernel | grep -q "2.6.32-358.el6.x86_64"; then
        echo "内核安装失败，请检查错误并手动安装"
        exit 1
    fi
    
    echo "内核安装成功，设置为默认启动内核..."
    
    # 直接修改 grub.conf 文件
    if [ -f "/boot/grub/grub.conf" ]; then
        # 查找目标内核的条目编号
        KERNEL_ENTRY=$(grep -n "2.6.32-358.el6.x86_64" /boot/grub/grub.conf | head -1 | cut -d":" -f1)
        if [ -n "$KERNEL_ENTRY" ]; then
            # 计算内核编号
            TITLE_COUNT=$(grep -n "^title" /boot/grub/grub.conf | wc -l)
            for i in $(seq 1 $TITLE_COUNT); do
                TITLE_LINE=$(grep -n "^title" /boot/grub/grub.conf | head -$i | tail -1 | cut -d":" -f1)
                if [ $TITLE_LINE -lt $KERNEL_ENTRY ] && [ $(grep -A10 "^title" /boot/grub/grub.conf | tail -n+$((($i-1)*10+1)) | head -10 | grep -c "2.6.32-358.el6.x86_64") -gt 0 ]; then
                    KERNEL_NUMBER=$((i-1))
                    break
                fi
            done
            
            # 设置默认启动项
            sed -i "s/^default=.*/default=$KERNEL_NUMBER/" /boot/grub/grub.conf
            echo "已将 2.6.32-358.el6.x86_64 内核设置为默认启动内核"
        else
            # 如果找不到目标内核，则采用备选方案
            echo "在 grub.conf 中找不到目标内核，使用更直接的方法..."
            
            # 直接修改 grub.conf
            GRUB_CONTENT=$(cat /boot/grub/grub.conf)
            TITLE_COUNT=$(echo "$GRUB_CONTENT" | grep -c "^title")
            
            # 如果有多个内核条目，则将新内核设置为默认
            sed -i "s/^default=.*/default=0/" /boot/grub/grub.conf
            
            # 确保新内核在第一位
            if [ $TITLE_COUNT -gt 0 ]; then
                # 备份原来的内容
                cp /boot/grub/grub.conf /boot/grub/grub.conf.old
                
                # 提取前面的内容（直到第一个 title 前）
                HEADER=$(sed -n '1,/^title/p' /boot/grub/grub.conf | head -n -1)
                
                # 生成新内核的条目
                NEW_ENTRY="title CentOS (2.6.32-358.el6.x86_64)\n\troot (hd0,0)\n\tkernel /vmlinuz-2.6.32-358.el6.x86_64 ro root=/dev/mapper/vg_centos-lv_root rd_NO_LUKS rd_LVM_LV=vg_centos/lv_root LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto rd_LVM_LV=vg_centos/lv_swap  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb quiet\n\tinitrd /initramfs-2.6.32-358.el6.x86_64.img"
                
                # 将原来的内容和新条目组合
                echo "$HEADER" > /boot/grub/grub.conf.new
                echo -e "$NEW_ENTRY" >> /boot/grub/grub.conf.new
                sed -n '/^title/,$p' /boot/grub/grub.conf >> /boot/grub/grub.conf.new
                
                # 替换原来的文件
                mv /boot/grub/grub.conf.new /boot/grub/grub.conf
            fi
            
            echo "已将新内核设置为默认启动项"
        fi
    else
        echo "找不到 grub.conf 文件，无法设置默认内核"
    fi
    
    # 更新 initramfs
    echo "生成 initramfs 文件..."
    dracut -f /boot/initramfs-2.6.32-358.el6.x86_64.img 2.6.32-358.el6.x86_64
    
    # 将当前内核移除（可选）
    CURRENT_KERNEL=$(uname -r)
    if [ "$CURRENT_KERNEL" != "2.6.32-358.el6.x86_64" ]; then
        echo "将在重启后移除当前内核 $CURRENT_KERNEL"
        echo "rpm -e kernel-$(echo $CURRENT_KERNEL | sed 's/-/_/g')" > /root/remove_old_kernel.sh
        chmod +x /root/remove_old_kernel.sh
        echo "@reboot root /root/remove_old_kernel.sh" >> /etc/crontab
    fi
    
    echo "内核已安装并设置为默认启动，系统将在10秒后重启..."
    echo "重启后请再次运行此脚本继续安装"
    sleep 10
    reboot
else
    # 检查当前运行的内核是否是指定版本
    CURRENT_KERNEL=$(uname -r)
    if [ "$CURRENT_KERNEL" != "2.6.32-358.el6.x86_64" ]; then
        echo "已安装指定内核，但当前运行的是 $CURRENT_KERNEL"
        echo "请重启系统并在 GRUB 菜单中手动选择 2.6.32-358.el6.x86_64 内核启动"
        exit 1
    else
        echo "当前已运行指定内核 2.6.32-358.el6.x86_64，继续安装过程"
    fi
fi

# 6. 卸载冲突软件
yum remove -y perl perl-DBI mysql mysql-*

# 7. 创建用户
echo "创建系统用户..."
sh create_user_kunshi.sh
sh create_user_kunshiweb.sh

# 8. 安装依赖
echo "安装系统依赖..."
yum install -y perl-DBI-1.40-5.i386.rpm

# 9. 数据库配置
echo "配置数据库连接..."

# 默认数据库配置
DB_TYPE="remote"  # 可选值: local 或 remote
REMOTE_DB_HOST="111.61.208.207"  # 远程数据库主机地址
REMOTE_DB_PORT="26"  # 远程数据库端口
REMOTE_DB_USER="root"  # 远程数据库用户名
REMOTE_DB_PASS="022018"  # 远程数据库密码

# 读取用户输入的数据库配置
echo -e "\033[33m请选择数据库安装类型 [1/2]:\033[0m"
echo "1. 本地数据库安装 (默认)"
echo "2. 远程数据库连接"
read -p "请输入选择 [1]: " DB_CHOICE

if [ "$DB_CHOICE" = "2" ]; then
    DB_TYPE="remote"
    read -p "请输入远程数据库主机地址: " REMOTE_DB_HOST
    read -p "请输入远程数据库端口 [3306]: " DB_PORT_INPUT
    if [ ! -z "$DB_PORT_INPUT" ]; then
        REMOTE_DB_PORT="$DB_PORT_INPUT"
    fi
    read -p "请输入远程数据库用户名 [root]: " DB_USER_INPUT
    if [ ! -z "$DB_USER_INPUT" ]; then
        REMOTE_DB_USER="$DB_USER_INPUT"
    fi
    read -p "请输入远程数据库密码: " REMOTE_DB_PASS
fi

# 根据选择安装或配置数据库
if [ "$DB_TYPE" = "local" ]; then
    echo "安装本地MySQL数据库..."
    rpm -ivh MySQL-server-community-5.0.96-1.rhel5.x86_64.rpm --nodeps --force
    rpm -ivh MySQL-client-community-5.0.96-1.rhel5.x86_64.rpm --nodeps --force
    cp -rf my.cnf /etc/my.cnf
    chmod 644 /etc/my.cnf
    service mysql restart
else
    echo "配置远程数据库连接..."
    # 只安装MySQL客户端
    rpm -ivh MySQL-client-community-5.0.96-1.rhel5.x86_64.rpm --nodeps --force
    
    # 测试远程数据库连接
    echo "测试远程数据库连接..."
    mysql -h"$REMOTE_DB_HOST" -P"$REMOTE_DB_PORT" -u"$REMOTE_DB_USER" -p"$REMOTE_DB_PASS" -e "SELECT 1;" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "\033[31m无法连接到远程数据库，请检查连接信息！\033[0m"
        exit 1
    fi
    echo -e "\033[32m远程数据库连接成功！\033[0m"
fi

# 10. 安装JDK和Tomcat
echo "安装JDK和Tomcat..."
rpm -ivh jdk-6u45-linux-amd64.rpm
tar zxvf apache-tomcat-7.0.23.tar.gz
mv apache-tomcat-7.0.23 /home/kunshiweb/base/apache-tomcat
tar -zxvf jrockit-jdk1.6.0_33-R28.2.4-4.1.0.tar.gz
cp -rf ./jrockit-jdk1.6.0_33-R28.2.4-4.1.0/ /home/kunshi/base/jdk_default
cp -rf ./jrockit-jdk1.6.0_33-R28.2.4-4.1.0/ /home/kunshiweb/base/jdk_default

# 11. 安装VOS3000核心组件
echo "安装VOS3000核心组件..."

# 如果使用远程数据库，修改VOS3000配置文件
if [ "$DB_TYPE" = "remote" ]; then
    echo "配置VOS3000使用远程数据库..."
    # 创建临时配置文件目录
    mkdir -p /tmp/vos_config
    
    # 解压rpm包中的配置文件
    echo "准备修改VOS3000数据库配置..."
fi
rpm -ivh emp-2.1.6-00.noarch.rpm
# 安装所有组件
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

# 如果使用远程数据库，修改VOS3000配置文件
if [ "$DB_TYPE" = "remote" ]; then
    echo "更新VOS3000数据库配置..."
    
    # 修改VOS3000主配置文件
    if [ -f "/home/kunshi/vos3000/etc/server.conf" ]; then
        sed -i "s/^dbhost=.*/dbhost=$REMOTE_DB_HOST/" /home/kunshi/vos3000/etc/server.conf
        sed -i "s/^dbport=.*/dbport=$REMOTE_DB_PORT/" /home/kunshi/vos3000/etc/server.conf
        sed -i "s/^dbuser=.*/dbuser=$REMOTE_DB_USER/" /home/kunshi/vos3000/etc/server.conf
        sed -i "s/^dbpassword=.*/dbpassword=$REMOTE_DB_PASS/" /home/kunshi/vos3000/etc/server.conf
    fi
    
    # 修改Web配置文件
    if [ -f "/home/kunshiweb/base/apache-tomcat/webapps/vos3000/WEB-INF/classes/jdbc.properties" ]; then
        sed -i "s/jdbc:mysql:\/\/localhost/jdbc:mysql:\/\/$REMOTE_DB_HOST/" /home/kunshiweb/base/apache-tomcat/webapps/vos3000/WEB-INF/classes/jdbc.properties
        sed -i "s/jdbc.username=.*/jdbc.username=$REMOTE_DB_USER/" /home/kunshiweb/base/apache-tomcat/webapps/vos3000/WEB-INF/classes/jdbc.properties
        sed -i "s/jdbc.password=.*/jdbc.password=$REMOTE_DB_PASS/" /home/kunshiweb/base/apache-tomcat/webapps/vos3000/WEB-INF/classes/jdbc.properties
    fi
    
    # 修改其他组件的数据库配置
    for config_file in $(find /home/kunshi -name "*.conf" -o -name "*.properties" | grep -i "db\|jdbc"); do
        if grep -q "jdbc:mysql" "$config_file" || grep -q "dbhost" "$config_file"; then
            echo "更新配置文件: $config_file"
            sed -i "s/jdbc:mysql:\/\/localhost/jdbc:mysql:\/\/$REMOTE_DB_HOST/g" "$config_file"
            sed -i "s/dbhost=localhost/dbhost=$REMOTE_DB_HOST/g" "$config_file"
            sed -i "s/dbport=3306/dbport=$REMOTE_DB_PORT/g" "$config_file"
            sed -i "s/dbuser=root/dbuser=$REMOTE_DB_USER/g" "$config_file"
            sed -i "s/jdbc.username=root/jdbc.username=$REMOTE_DB_USER/g" "$config_file"
            if [ ! -z "$REMOTE_DB_PASS" ]; then
                sed -i "s/dbpassword=.*/dbpassword=$REMOTE_DB_PASS/g" "$config_file"
                sed -i "s/jdbc.password=.*/jdbc.password=$REMOTE_DB_PASS/g" "$config_file"
            fi
        fi
    done
    
    echo -e "\033[32m已更新所有数据库配置文件为远程数据库\033[0m"
fi

# 12. 配置服务监控
echo "配置服务监控..."
cp -rf MbxWatch.sh /opt/MbxWatch.sh
echo "*/1 * * * * /opt/MbxWatch.sh" >> /var/spool/cron/root
service crond reload
service crond restart

# 13. 创建授权目录
mkdir -p /home/kunshi/license

# 14. 安装授权
echo "正在安装授权..."
chmod 777 vos30002160YZ.bin
./vos30002160YZ.bin

# 15. 显示系统信息
HIP=$(ip a|grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|grep -v "127"|awk '{print $2}')
echo -e $HIP >> HIP
MAC=$(ifconfig -a | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | head -1)
echo -e "\033[32m安装完成！\033[0m"
echo -e "\033[32m系统IP地址: $HIP\033[0m"
echo -e "\033[32m系统MAC地址: $MAC\033[0m"
echo -e "\033[32m游览器认证:ip:5101, 认证密码:shenz521, 登录账号密码:admin\033[0m"
echo -e "\033[32mSIP端口:62019,62019\033[0m"

# 16. 显示服务配置
head -2 /home/kunshi/vos3000/etc/server.conf | tail -1

# 显示数据库配置信息
if [ "$DB_TYPE" = "remote" ]; then
    echo -e "\033[32m远程数据库配置:\033[0m"
    echo -e "\033[32m  - 主机: $REMOTE_DB_HOST\033[0m"
    echo -e "\033[32m  - 端口: $REMOTE_DB_PORT\033[0m"
    echo -e "\033[32m  - 用户: $REMOTE_DB_USER\033[0m"
fi

echo "安装完成！"
