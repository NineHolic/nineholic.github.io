#!/bin/bash

# Author Nine
# Created in 2020-11-20

jvmpath=/usr/local/java
if [ ! -d "$jvmpath" ]; then
    sudo mkdir $jvmpath
    echo "目录 $jvmpath 创建成功"
fi

jdkfile=$(ls | grep jdk-*_linux-*.gz)

if [ -f "$jdkfile" ]; then
    sudo tar -zxvf $jdkfile -C $jvmpath	
    jdkdirname=$(ls $jvmpath | grep ^jdk-[0-9])	
    echo -e "\nJAVA_HOME=$jvmpath/$jdkdirname" >> /etc/profile
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
	echo "-------------------------------------------------------------"
	echo "$jdkdirname installed successfully."
	echo '* To start using java you need to run `source /etc/profile`'	
else
    echo "当前目录下无 jdk11 安装包"
fi
