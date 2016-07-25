#!/bin/bash
SCRIPT_DIR=$(cd `dirname $0`; pwd)
export JAVA_HOME="/usr/local/jdk1.7"
TOMCAT_HOME=""
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
#fi
echo "******************** 停止TOMCAT ******************"
if [ ! -f $TOMCAT_HOME/bin/shutdown.sh ];then
        echo "错误:$TOMCAT_HOME/bin/shutdown.sh不存在."
        exit 1
fi
i=0
code=0
echo "Stop  Tomcat..."
echo "$TOMCAT_HOME/bin/shutdown.sh"
while [ $i -lt 60 ]&&[ $code -eq 0 ];do
	$TOMCAT_HOME/bin/shutdown.sh 
        sleep 1
        netstat -tlnp|awk '{print $4}'|grep -E ":$TOMCAT_PORT$" >/dev/null 2>/dev/null
        code=$?
        echo "等待 $i 秒......"
        i=`expr $i + 1`
done
netstat -tlnp|awk '{print $4}'|grep -E ":$TOMCAT_PORT$"
if [ $? -eq 0 ];then
        echo "警告:$TOMCAT_HOME/bin/shutdown.sh 执行失败.准备强杀进程。"
        lsof -i:$TOMCAT_PORT|sed '1d'|awk '{print $2}'|xargs kill -9
fi
sleep 3
netstat -tlnp|awk '{print $4}'|grep -E ":$TOMCAT_PORT$"
if [ $? -eq 0 ];then
        echo "Stop Tomcat "
        exit 1
fi
echo "停止tomcat成功!!!"
exit 0
