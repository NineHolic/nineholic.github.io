#!/bin/bash

# author：Nine
# create：2020-11-20
# note: 安装配置 jdk11

jvmpath=/usr/local/java
jdkfile=$(find "$(pwd)" -name "jdk-11*linux*.gz")

if [ -f "$jdkfile" ]; then
    if [ ! -d "$jvmpath" ]; then
        sudo mkdir -p $jvmpath && "目录 $jvmpath 创建成功"
    fi
    sudo tar -zxvf "$jdkfile" -C $jvmpath
    jdkdirname=$(find $jvmpath -maxdepth 1 -type d -name 'jdk-11*')
    {
        echo -e "\nJAVA_HOME=$jdkdirname"
        echo "export PATH=\$PATH:\$JAVA_HOME/bin"
    } >>/etc/profile
    printf '%.0s-' {1..70}
    echo -e "\n$jdkdirname installed successfully."
    echo "* To start using jdk you need to run: source /etc/profile"
else
    echo "当前目录下无 jdk11 安装包"
fi
