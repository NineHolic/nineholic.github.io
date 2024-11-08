#!/bin/bash

# author：Nine
# create：2020-11-20
# note: 安装配置 jdk8

jvmpath=/usr/local/java
jdkfile=$(find "$(pwd)" -name "jdk-8*linux*.gz")

if [ -f "$jdkfile" ]; then
    if [ ! -d "$jvmpath" ]; then
        sudo mkdir -p $jvmpath && "目录 $jvmpath 创建成功"
    fi
    sudo tar -zxvf "$jdkfile" -C $jvmpath
    jdkdirname=$(find $jvmpath -maxdepth 1 -type d -name 'jdk1.8*')
    {
        echo -e "\nJAVA_HOME=$jdkdirname"
        echo "JRE_HOME=$jdkdirname/jre"
        echo "CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib"
        echo "PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin"
        echo "export JAVA_HOME JRE_HOME CLASSPATH PATH"
    } >>/etc/profile
    printf '%.0s-' {1..70}
    echo -e "\n$jdkdirname installed successfully."
    echo "* To start using jdk you need to run: source /etc/profile"
else
    echo "当前目录下无 jdk1.8 安装包"
fi
