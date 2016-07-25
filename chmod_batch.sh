#!/bin/bash
SCRIPT_DIR=/data/deploy/scripts
OPER="$1"
CHECK_FILE_LIST=$2
[ ! -f $SCRIPT_DIR/$CHECK_FILE_LIST ]&&echo "$SCRIPT_DIR/$CHECK_FILE_LIST 文件不存在"&&exit 1
cat $SCRIPT_DIR/$CHECK_FILE_LIST|grep -Ev "^[::space::]*#"|while read file;do
	chmod $1 $file
	[ $? -ne 0 ]&&echo "chmod $1 $file 操作失败."
done 
cat $SCRIPT_DIR/$CHECK_FILE_LIST|grep -Ev "^[::space::]*#"|while read file;do
        ls -l $file 
done

