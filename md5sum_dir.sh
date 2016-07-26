#!/bin/bash
dir=$1
dir2=$2
#比较目录dir中dir2对应的文件md5值是否相等，如果不等或者dir2不存在这个文件，则打印出来
find $dir -type f|while read file;do
	subfix_file=`echo "$file"|sed s#^$dir##g|sed s#^/##g`
	file2="`echo \"$dir2/$subfix_file\"|sed s#//#/#g`"
	if [ ! -f "$file2" ];then
                echo -e "${dir2} \033[33m不存在文件 $subfix_file\033[0m"
		continue
	fi
	m1=`md5sum "$file"|awk '{ print $1}'`
	m2=`md5sum "$file2"|awk '{ print $1}'`
	#打印不同结果
	if [ x"$m1" != x"$m2" ];then
		echo -e "$subfix_file \033[31m文件校验值不一致\033[0m"
		echo -e "	$m1"
		echo -e "	$m2"
	fi
done
#反向比较
#比较目录dir2是否存文件在dir不存在这个文件，则打印出来
find $dir2 -type f|while read file;do
        subfix_file=`echo "$file"|sed s#^$dir2##g|sed s#^/##g`
        file2="`echo \"$dir/$subfix_file\"|sed s#//#/#g`"
        if [ ! -f "$file2" ];then
                echo -e "${dir} \033[33m不存在文件 $subfix_file\033[0m"
		continue	
        fi
done

