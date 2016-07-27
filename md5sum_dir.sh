#!/bin/bash
if [ $# -lt 2 ];then
	echo -e "使用方法:\n$0 dir dir2 #dir,dir2为目录,为必须参数\n\t-p 开启权限比较\n\t-o 开启所属用户和所属组的比较\n\t--type=[f|d|file|dir] 指定进行比较文件还是目录"
	exit 1
fi
DIR=$1
DIR2=$2
GRANT=0
OWNER=0
[ ! -d $DIR ]&&echo "${DIR}不存在或者不是一个目录"&&exit 1
[ ! -d $DIR2 ]&&echo "${DIR2}不存在或者不是一个目录"&&exit 1
shift
shift
for var in "$@"
do
	case $var in
		-p|--perm)
		GRANT=1
		;;
		-o|--owner)
		OWNER=1
		;;
		--type=f|--type=file)
		TYPE="f"
		;;
		--type=d|--type=dir)
		TYPE="d"
		;;
		*)
		echo -e "参数错误:没有这个参数\n使用方法:\n脚本 目录1 目录2\n\t-p 开启权限比较\n\t-o开启所属用户和所属组的比较\n\t--type=[f|d|file|dir] 指定进行比较文件还是目录"
		exit 1
		;;
	esac
done
MD5=1
FILE_NAME="文件"
TYPE=${TYPE:-f}
if [ x"$TYPE" == x"d" ];then
	MD5=0
	FILE_NAME="目录"
fi

# 比较目录DIR中DIR2对应的文件md5值是否相等，如果不等或者DIR2不存在这个文件，则打印出来
find $DIR -type $TYPE|while read FILE;do
	SUBFIX_FILE=`echo "$FILE"|sed s#^$DIR##g|sed s#^/##g`
	FILE2="`echo \"$DIR2/$SUBFIX_FILE\"|sed s#//#/#g`"
	if [ x"$TYPE" == x"d" ];then
		if [ ! -d "$FILE2" ];then
            echo -e "\033[33m目录${DIR2}缺少目录$SUBFIX_FILE\033[0m"
            continue
        fi
	else
		if [ ! -f "$FILE2" ];then
            echo -e "\033[33m目录${DIR2}缺少文件$SUBFIX_FILE\033[0m"
			continue
		fi
		
	fi

	if [ $MD5 -eq 1 ];then
		MD5_1=`md5sum "$FILE"|awk '{ print $1}'`
		MD5_2=`md5sum "$FILE2"|awk '{ print $1}'`
		if [ x"$MD5_1" != x"$MD5_2" ];then
			echo -e "\033[31m文件校验值不一致\033[0m"
			echo -e "$MD5_1 $FILE"
			echo -e "$MD5_2 $FILE2"
		fi
	fi
	if [ $GRANT -eq 1 ];then
		GRANT1=`([ -f "$FILE" ]&&ls -l "$FILE"|awk '{ print $1}')||([ -d "$FILE" ]&&ls -ld "$FILE"|awk '{ print $1}')`
		GRANT2=`([ -f "$FILE2" ]&&ls -l "$FILE2"|awk '{ print $1}')||([ -d "$FILE2" ]&&ls -ld "$FILE2"|awk '{ print $1}')`
		if [ x"$GRANT1" != x"$GRANT2" ];then
           	echo -e "\033[31m${FILE_NAME}权限不一致\033[0m"
           	echo -e "$GRANT1 $FILE"
           	echo -e "$GRANT2 $FILE2"
       	fi	
	fi
	if [ $OWNER -eq 1 ];then
		OWNER1=`([ -f "$FILE" ]&&ls -l "$FILE"|awk '{ print $3}')||([ -d "$FILE" ]&&ls -ld "$FILE"|awk '{ print $3}')`
		OWNER2=`([ -f "$FILE2" ]&&ls -l "$FILE2"|awk '{ print $3}')||([ -d "$FILE2" ]&&ls -ld "$FILE2"|awk '{ print $3}')`
		GROUP1=`([ -f "$FILE" ]&&ls -l "$FILE"|awk '{ print $4}')||([ -d "$FILE" ]&&ls -ld "$FILE"|awk '{ print $4}')`
		GROUP2=`([ -f "$FILE2" ]&&ls -l "$FILE2"|awk '{ print $4}')||([ -d "$FILE2" ]&&ls -ld "$FILE2"|awk '{ print $4}')`
		if [ x"$OWNER1" != x"$OWNER2" ]||[ x"$GROUP1" != x"$GROUP2" ];then
			echo -e "\033[31m${FILE_NAME}所有者或者所属组不一致\033[0m"
			echo -e "$OWNER1:$GROUP1 $FILE"
			echo -e "$OWNER2:$GROUP2 $FILE2"
		fi
	fi
done
#反向比较
#比较目录DIR2是否存文件在DIR不存在这个文件，则打印出来
find $DIR2 -type $TYPE|while read FILE;do
	SUBFIX_FILE=`echo "$FILE"|sed s#^$DIR2##g|sed s#^/##g`
    FILE2="`echo \"$DIR/$SUBFIX_FILE\"|sed s#//#/#g`"
	if [ x"$TYPE" == x"d" ];then
		if [ ! -d "$FILE2" ];then
			echo -e "\033[33m目录${DIR}缺少目录$SUBFIX_FILE\033[0m"
            continue
        fi
    else
        if [ ! -f "$FILE2" ];then
            echo -e "\033[33m目录${DIR}缺少文件$SUBFIX_FILE\033[0m"
            continue
        fi
    fi
done

