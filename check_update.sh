#!/bin/bash
if [ $# -lt 2 ];then
	echo -e "使用方法:\n$0 old=目录1 new=目录2 [-p|-o|--type=[f|d|file|dir]]\n\told=目录1 被比较的目录\n\tnew=目录2 比较的目录\n\t-p 开启权限比较\n\t-o 开启所属用户和所属组的比较\n\t--type=[f|d|file|dir] 指定进行比较文件还是目录,f或者file表示文件比较,d或者dir表示目录比较\n\t--print-md5sum 如果md5校验值不同,则打印被md5校验值"
	exit 1
fi
DIR=""
DIR2=""
GRANT=0
OWNER=0
PRINT_MD5=0
UPGRADE=0
ROLLBACK=0
for var in "$@"
do
	case $var in
		old=*)
		DIR=`echo "$var"|cut -d= -f2-`
		;;
		new=*)
		DIR2=`echo "$var"|cut -d= -f2-`
		;;
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
		--print-md5sum)
		PRINT_MD5=1
		;;
		--rollback)
		ROLLBACK=1
		;;
		*)
		echo -e "参数错误:参数${var}不能匹配\n使用方法:\n$0 old=目录1 new=目录2 [-p|-o|--type=[f|d|file|dir]]\n\told=目录1 被比较的目录\n\tnew=目录2 比较的目录\n\t-p 开启权限比较\n\t-o 开启所属用户和所属组的比较\n\t--type=[f|d|file|dir] 指定进行比较文件还是目录,f或者file表示文件比较,d或者dir表示目录比较\n\t--print-md5sum 如果md5校验值不同,则打印被md5校验值"
		exit 1
		;;
	esac
done
echo "$DIR,$DIR2"
[ ! -d $DIR ]&&echo "${DIR}不存在或者不是一个目录"&&exit 1
[ ! -d $DIR2 ]&&echo "${DIR2}不存在或者不是一个目录"&&exit 1
MD5=1
FILE_NAME="文件"
TYPE=${TYPE:-f}
if [ x"$TYPE" == x"d" ];then
	MD5=0
	FILE_NAME="目录"
fi

# 比较目录DIR中DIR2对应的文件md5值是否相等，如果不等或者DIR2不存在这个文件，则打印出来
if [ $ROLLBACK -eq 1 ];then
	echo -e "\033[35m对回滚前后进行md5校验,检测文件是否回滚成功$SUBFIX_FILE\033[0m"
else
	echo -e "\033[35m对升级前后进行md5校验,检测实际更新的文件$SUBFIX_FILE\033[0m"
fi
echo "++++++++++++++++++++++++++++++++++++++++++++"
find $DIR2 -type $TYPE >temp_dir.txt
while read FILE;do
	SUBFIX_FILE=`echo "$FILE"|sed s#^$DIR2##g|sed s#^/##g`
	FILE2="`echo \"$DIR/$SUBFIX_FILE\"|sed s#//#/#g`"
	SUBDIR=`echo $SUBFIX_FILE|sed 's#^\(.*\/\)\([^/]*\)$#\1#g'`
	SUBFILE=`echo $SUBFIX_FILE|sed 's#^\(.*\/\)\([^/]*\)$#\2#g'`
	if [ x"$TYPE" == x"d" ];then
		if [ ! -d "$FILE2" ];then
			if [ $ROLLBACK -eq 0 ];then
            	echo -e "${DIR2}\t\033[33m新增目录+\033[0m\t$SUBFIX_FILE"
			fi 
            continue
        fi
	else
		if [ ! -f "$FILE2" ];then
			if [ $ROLLBACK -eq 0 ];then
            	echo -e "${DIR2}\t\033[33m新增文件+\033[0m\t$SUBFIX_FILE"
			fi
			continue
		fi
		
	fi

	if [ $MD5 -eq 1 ];then
		MD5_1=`md5sum "$FILE"|awk '{ print $1}'`
		MD5_2=`md5sum "$FILE2"|awk '{ print $1}'`
		if [ x"$MD5_1" != x"$MD5_2" ];then
			UPGRADE=1
            echo -e "${DIR2}\t\033[32m更新文件\033[0m\t$SUBFIX_FILE"
			if [ $PRINT_MD5 -eq 1 ];then
				echo -e "$MD5_1 $FILE"
				echo -e "$MD5_2 $FILE2"
			fi
		fi
	fi
done <temp_dir.txt
rm -f temp_dir.txt
if [ $UPGRADE -eq 0 ];then
	if [ $ROLLBACK -eq 1 ];then
		echo -e "\033[40;32m 恭喜回滚成功!!!\033[0m"
	else
		echo -e "\033[40;33m $DIR2 升级前后所有文件内容无变化!!!\033[0m"
	fi
else
	if [ $ROLLBACK -eq 1 ];then
        echo -e "\033[40;31m 错误:回滚失败!!!\033[0m"
		exit 1
	fi
fi
echo "++++++++++++++++++++++++++++++++++++++++++++"
#反向比较
