#!/bin/bash -v

# author：Nine
# create: 2021-05-23
# note: 安装配置 git

gitpath=/usr/local/git
git_v='2.45.0'

# 安装依赖
function check_os() {
	# CentOS
	if test -e "/etc/redhat-release"; then
		yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker autoconf automake libtool wget
		[ $? -ne 0 ] && echo "yum 安装依赖失败，请手动安装" && exit 0
	# Debian
	elif test -e "/etc/debian_version"; then
		apt-get -y install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev gcc make wget dh-autoreconf
		[ $? -ne 0 ] && echo "apt-get 安装依赖失败，请手动安装" && exit 0
	else
		echo "该脚本不适用当前系统！" && exit 0
	fi
}

# 编译安装
function install() {
	yum -y remove git
	if [ ! -f "git-$git_v.tar.gz" ]; then
		wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-$git_v.tar.gz
		[ $? -ne 0 ] && echo "git-$git_v.tar.gz 文件下载失败" && exit 1
	fi
	tar -zxvf git-$git_v.tar.gz && cd git-$git_v
	make configure
	./configure --prefix=$gitpath
	make -j2 all && make -j2 install
	ln -s $gitpath/bin/git /usr/bin/git
	echo "-------------------------------------------------------------"
	echo "installed successfully."
	git --version
}

check_os
install
