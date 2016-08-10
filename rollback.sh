#!/bin/bash
PROJECT="$1"
ENV="$2"
TOMCAT_HOME="$3"
ROLLBACK_VERSION="`echo $4|awk -Fnow- '{ print $2}'`"
ROLLBACK_DIR="/data/rollback/$ENV/$PROJECT"
FILE_SUBFIX=`date +%Y%m%d_%H%M%S`
[ ! -d $ROLLBACK_DIR ]&&mkdir -p $ROLLBACK_DIR
[ ! -f /data/deploy/scripts/upgrade/$ENV/$PROJECT/last_${PROJECT}_${ENV}_build.txt ]&&echo -e "\033[33m错误:last_${PROJECT}_${ENV}_build.txt文件不存在!\034[0m"&&exit 1
BACKUP_NUMS=`wc -l /data/deploy/scripts/upgrade/$ENV/$PROJECT/last_${PROJECT}_${ENV}_build.txt|awk '{ print $1}'`
if [ $ROLLBACK_VERSION -gt $BACKUP_NUMS ];then
	echo -e "\033[33m错误:回退版本不存在!\033[0m"
	exit 1
fi
BACKUP_DIR="`tail -$ROLLBACK_VERSION /data/deploy/scripts/upgrade/$ENV/$PROJECT/last_${PROJECT}_${ENV}_build.txt|head -1|sed 's/\/$//g'`"
[ ! -d $BACKUP_DIR ]&&echo -e "\033[33m错误:$BACKUP_DIR目录不存在!\033[0m"&&exit 1

VERSION_DATE=`echo $BACKUP_DIR|awk -F/ '{ print $NF }'|cut -d_ -f2-|sed 's#\(....\)\(..\)\(..\)_\(..\)\(..\)\(..\)#\1/\2/\3 \4:\5:\6#g'`
echo -e "\033[32m注意:回滚到备份时间点$VERSION_DATE\033[0m"
cd $BACKUP_DIR 
echo "mv $TOMCAT_HOME/webapps/$PROJECT/ $ROLLBACK_DIR/${PROJECT}_${FILE_SUBFIX}"
mv $TOMCAT_HOME/webapps/$PROJECT/ $ROLLBACK_DIR/${PROJECT}_${FILE_SUBFIX}
mkdir -p $TOMCAT_HOME/webapps/$PROJECT/
cd $BACKUP_DIR 
cp -r * $TOMCAT_HOME/webapps/$PROJECT/
[ $? -ne 0 ]&&echo -e "\033[31m错误:回滚拷贝遇到问题!\033[0m"&&exit 1
echo "$BACKUP_DIR" >>/data/deploy/scripts/upgrade/$ENV/$PROJECT/last_${PROJECT}_${ENV}_rollback.txt
#cd backup_dir
#cp -r * $TOMCAT_HOME/webapps/$PROJECT

