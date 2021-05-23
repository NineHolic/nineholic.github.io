#!/bin/bash

# Author Nine
# Created in 2020-11-20

jvmpath=/usr/local/java
if [ ! -d "$jvmpath" ]; then
    sudo mkdir $jvmpath
    echo "目录 $jvmpath 创建成功"
fi

jdkfile=$(ls | grep jdk-8*-linux-*.gz)

if [ -f "$jdkfile" ]; then
    sudo tar -zxvf $jdkfile -C $jvmpath	
    jdkdirname=$(ls $jvmpath | grep ^jdk[0-9])
    echo -e "\nJAVA_HOME=$jvmpath/$jdkdirname" >> /etc/profile
    echo "JRE_HOME=$jvmpath/$jdkdirname/jre" >> /etc/profile
    echo 'CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib' >> /etc/profile
    echo 'PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin' >> /etc/profile
    echo "export JAVA_HOME JRE_HOME CLASS_PATH PATH" >> /etc/profile
	echo "-------------------------------------------------------------"
	echo "$jdkdirname installed successfully."
	echo '* To start using java you need to run `source /etc/profile`'	
else
    echo "当前目录下无 jdk1.8 安装包"
fi

