#!/bin/bash
SCRIPT_DIR=$(cd `dirname $0`; pwd)
export JAVA_HOME="/usr/local/jdk1.7"
source $HOME/.bashrc
while [ $# -ne 0 ];do
        echo $1|grep -iE "ip="&&TOMCAT_IP=`echo $1|tr '[A-Z]' '[a-z]'|awk -F= '{print $2}'`
        echo $1|grep -iE "port="&&TOMCAT_PORT=`echo $1|tr '[A-Z]' '[a-z]'|awk -F= '{print $2}'`
        echo $1|grep -iE "tomcat_home="&&TOMCAT_HOME=`echo $1|tr '[A-Z]' '[a-z]'|awk -F= '{print $2}'`
        shift
done
TOMCAT_IP="${TOMCAT_IP:-0.0.0.0}"
if [ x"$TOMCAT_PORT" == x"" ];then
        echo -e "错误:没有指定脚本port参数\n使用方法:bash $SCRIPT_DIR/$0 port=8080 #其中8080就是tomcat的监听"
        exit 1
fi
if [ x"$TOMCAT_HOME" == x"" ];then
        echo -e "错误:没有指定脚本tomcat_home参数\n使用方法:bash $SCRIPT_DIR/$0 tomcat_home=/data/app/tomcat #其中/data/app/tomcat就是TOMCAT根目录"
        exit 1
fi
JAVA_OPTS=`grep -E "^[[:space:]]*JAVA_OPTS=" ${TOMCAT_HOME}/bin/catalina.sh|head -1|cut -d= -f2-|sed -e "s/^[\"|']//g" -e "s/[\"|']$//g"`
export JAVA_OPTS

echo "********************* 启动TOMCAT ******************"
sleep 2
netstat -tlnp|awk '{print $4}'|grep -E ":$TOMCAT_PORT$"
if [ $? -eq 0 ];then
        echo "Tomcat已经在运行!!!"
	exit 0
fi
$TOMCAT_HOME/bin/startup.sh
sleep 3
netstat -tlnp|awk '{print $4}'|grep -E ":$TOMCAT_PORT$"
if [ $? -eq 0 ];then
        echo "Tomcat启动成功!!!"
else
        echo "Tomcat启动失败!!!"
        exit 1
fi
exit 0

