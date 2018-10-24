# -*- coding: utf-8 -*-
import requests
import time
import json
import hashlib
import xml.dom.minidom

import sys
reload(sys)
sys.setdefaultencoding('utf-8')


PROJECT=sys.argv[1]
ENV=sys.argv[2]
BUILD_USER=sys.argv[3]
SVN_URL=sys.argv[4]
SVN_REVISION=sys.argv[5]
JOB_RESULT=sys.argv[6]
BUILD_URL=sys.argv[7]
ACCESS_TOKEN=sys.argv[8]
HEADERS = {'ua': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.125 Safari/537.36'}
DINGDING_URL= 'https://oapi.dingtalk.com/robot/send?access_token='+ACCESS_TOKEN

class Message():

    def __init__(self,project,env,build_user,svn_url,svn_revision,job_result,build_url):
		self.project=project
		self.env=env
		self.build_user=build_user
		self.svn_url=svn_url
		self.svn_revision=svn_revision
		self.job_result=job_result
		self.build_url=build_url

    def send_message_to_robot(self):
        url= DINGDING_URL
        message='''# [jenkins发布通知]({})
### 项目: {}
### 环境: {}
### SVN标签: [{}]({}) 
### SVN版本号: {}
### 执行人: {}
### 执行时间: {}
### 执行结果: {}
'''.format(self.build_url,self.project,self.env,self.svn_url.split('/')[-1],self.svn_url,self.svn_revision,self.build_user,time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()),self.job_result)
        data={"msgtype":"markdown",
			  "markdown":{"title":"构建通知",
				"text":message},
		}
        try:
            resp = requests.post(url,headers=HEADERS,json=data,timeout=(3,60))
        except:
            print ("Send Message is fail!");



if __name__ == '__main__':
    message = Message(PROJECT,ENV,BUILD_USER,SVN_URL,SVN_REVISION,JOB_RESULT,BUILD_URL)
    message.send_message_to_robot();
