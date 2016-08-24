#!/bin/sh

#  Kritro.sh
#  
#
#  Created by Kritro on 16/8/24.
#

#! /bin/sh

echo "Enter password:"
read TRY
while [ "$TRY" != "secret" ]; do
  echo "Sorry, try again"
  read TRY
done

function install() {
    echo "*****************************************************************"
	echo " Welcome you use Kritro write a key erection DNF service script"                  
	echo "          感谢您使用Kritro一键架设DNF商业版!"
	echo "           Our web site：www.1nvincible.online"
	echo "              我们的网站：1nvincible.online"
	echo "         Created by Kritro on 16/8/24.最后一次整理!"
	echo "******************************************************************"
    read -p "请输入Linux CentOS版本	例如5.11 输入“5”回车：" versionNumber
#TODO:直接取系统版本号判断，再检测文件是否存在，不符合都跳出
    read -p "请选择服务器环境，2.国外(需要自行更换秘钥及PVF文件) 3.自备Server.tar.gz及公钥及PVF文件(此项开始前要确保根目录下存在Server.tar.gz、publickey.pem、Script.pvf)，优先选”3“回车：" networkState
    if (($versionNumber==5)); then
        installSupportLibOnCentOS5
    elif (($versionNumber==6)); then
        installSupportLibOnCentOS6
    else
        echo "仅支持只有5.x和6.x"
        exit 0
    fi
    echo "添加虚拟内存 耐心等待……"
    addSwap
    Kritro
    deleteRoot6686
    removeTemp
}

function getIP() {
    echo "正在获取当前服务器IP..."
    IP=`curl -s http://v4.ipv6-test.com/api/myip.php`
    if [ -z $IP ]; then
    IP=`curl -s https://www.boip.net/api/myip`
    fi
}

function addSwap() {
    echo "正在添加虚拟内存(Swap) 请耐心等待..."
#   if read -n1 -p "请输入虚拟内存大小（正整数、单位为GB、默认6  GB）" answer
#   then
#   /bin/dd if=/dev/zero of=/var/swap.Kritro bs=1M count=1000*$answer
    /bin/dd if=/dev/zero of=/var/swap.Kritro bs=1M count=8000
    mkswap /var/swap.Kritro
    swapon /var/swap.Kritro
#   加入开机自启动
#   $ 最后一行
#   a 在该指令前面的行数后面插入该指令后面的内容
    sed -i '$a /var/swap.Kritro swap swap default 0 0' /etc/fstab
    echo "添加虚拟内存(Swap) Success!!"
}

function installSupportLibOnCentOS5() {
    echo "正在安装运行库for CentOS 5.x..."
    if (($networkState==3)); then
        wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo
        yum clean all
        yum makecache
    fi
    yum -y update
    yum -y upgrade
    yum -y install mysql-server
    yum -y install gcc gcc-c++ make zlib-devel
    yum -y install libstdc++
    yum -y install glibc.i686
    yum -y install libc.so.6
#   添加到开机自启动
    chkconfig mysqld on
    service mysqld start
    service mysqld enable
}

function installSupportLibOnCentOS6() {
    echo "正在安装运行库for CentOS 6.x..."
    if (($networkState==1)); then
        wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
        yum clean all
        yum makecache
    fi
    yum -y update
    yum -y upgrade
    yum -y remove mysql-libs.x86_64
    yum -y install mariadb-server
    yum -y install gcc gcc-c++ make zlib-devel
    yum -y install xulrunner.i686
    yum -y install libXtst.i686
    systemctl start mariadb
    systemctl enable mariadb.service
}

function Kritro() {
    getIP
    echo -n "${IP} 是否是你的外网IP?(如果不是你的外网IP或者出现两条IP地址 请输入 n 回车后自行输入!) y/n [n] ?"
    read ans
    case $ans in
    y|Y|yes|Yes)
    ;;
    n|N|no|No)
    read -p "输入你的外网IP地址 回车（确保是英文字符的点号）：" myip
    IP=$myip
    ;;
    *)
    ;;
    esac
    cd ~
    echo "下载Server..."
    if (($networkState==5)); then
        cd ~
    #   Kritro
    elif (($networkState==3)); then
        cd ~
    else
        wget -O /root/Server.tar.gz https://下载地址
        wget -O /root/Script.pvf https://下载地址
        wget -O /root/publickey.pem https://下载地址
    fi
    cp Server.tar.gz /
    cd /
    tar -zvxf Server.tar.gz
    tar -zvxf var.tar.gz
    cd /home/GeoIP-1.4.8/
    ./configure
    make && make check && make install
    cd /home/Kritro/
    sed -i "s/1.1.1.1/${IP}/g" `find . -type f -name "*.tbl"`
    sed -i "s/1.1.1.1/${IP}/g" `find . -type f -name "*.cfg"`
    cp /root/Script.pvf /home/Kritro/game/
    cp /root/publickey.pem /home/Kritro/game/
    echo "添加防火墙端口..."
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 8000 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 10013 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 30303 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 30403 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 10315 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 30603 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 20203 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 7215 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 20303 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 40401 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 30803 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 20403 -j ACCEPT' /etc/sysconfig/iptables
    sed -i '/INPUT.*NEW.*22/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 31100 -j ACCEPT' /etc/sysconfig/iptables
#   端口不全，这里先把防火墙关了
    service iptables stop
#   TODO:关闭防火墙自启动
    service mysqld restart
    systemctl restart mariadb
}

function deleteRoot6686() {
    HOSTNAME="127.0.0.1"
    PORT="3306"
    USERNAME="game"
    PASSWORD="uu5!^%jg"
    DBNAME="mysql"
    TABLENAME="user"
    refresh="flush privileges;";
    delete_user_root6686="delete from mysql.user where user='root9326686' and host='%';"
#  delete_user_cash="delete from mysql.user where user='cash' and host='127.0.0.1';"
    mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${delete_user_root6686}"
#  mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${delete_user_cash}"
    mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${refresh}"
}

function removeTemp() {
    echo -n -t 5 "架设完成!!是否删除临时文件 y/n [n] ?"
    read ANS
    case $ANS in
    y|Y|yes|Yes)
    rm -f /root/mysql57*
    rm -f /var.tar.gz
    rm -f /etc.tar.gz
    rm -f /Server.tar.gz
    ;;
    n|N|no|No)
    ;;
    *)
    ;;
    esac
}

install
echo "********************************************************"
echo "                    IP = ${IP}"
echo "          感谢您使用Kritro一键架设DNF商业版!"
echo "           我们的网站：www.1nvincible.online"
echo "              制作者：Kritro QQ 3332425262"
echo "         Created by Kritro on 16/8/24.最后一次整理!"
echo "********************************************************"
