#!/bin/bash
DEPLOY_HOME="/data/app/deploy/"
PROJECT="$1"
ENV_TYPE="$2"
JENKINS_HOME="$3"
PROJECT_NAME="${PROJECT}_${ENV_TYPE}"
WORKSPACE_HOME="$JENKINS_HOME/workspace/"
#BUILD_HOME="$WORKSPACE_HOME/$PROJECT_NAME/target/${PROJECT}-1.0.0-BUILD-SNAPSHOT/"
BUILD_HOME="$WORKSPACE_HOME/$PROJECT_NAME/target/${PROJECT}*"
USER_DIR="$ENV_TYPE"
CHANG_LIST_DIR="$DEPLOY_HOME/project_changed_lists/$USER_DIR"
CHANG_LIST="${PROJECT}_${ENV_TYPE}_changed_list.txt"
EXTACT_DIR="$DEPLOY_HOME/extract_files"
SCRIPT_DIR="$DEPLOY_HOME/scripts"
LOG_DIR="$SCRIPT_DIR"
LOG_FILE="extract_file.log"
SVN_URL=$4
SVN_REVISION=$5
ECHO_PREFIX=""
ECHO_SUFFIX="\033[0m"
FILE_FLAG=0
TEMP_DIR=$SCRIPT_DIR/temp
TEMP_FILE="temp_${PROJECT}_${ENV_TYPE}_`date +%Y%m%d_%H%M%S`"
# echo -e "${ECHO_PREFIX}rm -r $EXTACT_DIR/$PROJECT_NAME${ECHO_SUFFIX}"
[ -d $EXTACT_DIR/$PROJECT_NAME ]&&rm -r $EXTACT_DIR/$PROJECT_NAME
[ ! -d $EXTACT_DIR/$PROJECT_NAME ]&&mkdir -p $EXTACT_DIR/$PROJECT_NAME
cd $BUILD_HOME || cd $WORKSPACE_HOME/$PROJECT_NAME/

echo -e "${ECHO_PREFIX}${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}时间:`date`${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}##### $PROJECT_NAME  #####${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}JENKINS_HOME:$JENKINS_HOME${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}PROJECT_NAME:$PROJECT_NAME${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}BUILD_HOME:$BUILD_HOME${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}USER_DIR:$USER_DIR${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}CHANG_LIST:$CHANG_LIST${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}SVN URL:$SVN_URL${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "${ECHO_PREFIX}SVN REVISION:$SVN_REVISION${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE

echo -e "${ECHO_PREFIX}++++++++++++++++++++++++++++++++++++++++++++${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo "$6" |grep -v "^#"|grep -v "^$"|grep -vE "^[[:space:]]+$"|sed 's/^\///g' >$TEMP_DIR/$TEMP_FILE
while read file;do
	echo -e "\033[32m抽取文件 /$file ${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE 
	cp -r --parents $file $EXTACT_DIR/$PROJECT_NAME
echo "$BUILD_HOME" > /tmp/log
	[ $? -ne 0 ]&&FILE_FLAG=1
	#抽取内部类
	if [ x"${file##*.}" == x"class" ];then
		file_prefix="${file%.*}"	
		file_subfix="${file##*.}"
		file_ex="${file_prefix}\$*.$file_subfix"
		cp -r --parents $file_ex $EXTACT_DIR/$PROJECT_NAME >/dev/null 2>/dev/null
	fi
done < $TEMP_DIR/$TEMP_FILE
	
echo -e "${ECHO_PREFIX}++++++++++++++++++++++++++++++++++++++++++++${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
cd $EXTACT_DIR/$PROJECT_NAME
echo -e "\033[34m抽取出文件树结构:${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE
echo -e "\033[34m`tree *`${ECHO_SUFFIX}" |tee -a $LOG_DIR/$LOG_FILE 
