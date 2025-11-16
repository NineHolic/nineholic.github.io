---
layout: post
title: Docker 的安装与使用
categories: [Docker]
description: Docker 的安装与使用
keywords: Docker, Linux, Centos, Ubuntu
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

Docker 是一个开源的应用容器引擎，可以让开发者打包他们的应用以及依赖包到一个轻量级、可移植的容器中，然后发布到任何流行的 Linux 机器上，也可以实现虚拟化。 容器是完全使用沙箱机制，相互之间不会有任何接口（类似 iPhone 的 app），更重要的是容器性能开销极低。

##### 1、centos 安装 docker

Docker 从 17.03 版本之后分为 CE 和 EE 两大版本。CE 即社区版（免费，支持周期 7 个月），EE 即企业版，强调安全，付费使用，支持周期 24 个月。

Docker CE 支持 64 位版本 CentOS 7，并且要求内核版本不低于 3.10， CentOS 7 满足最低内核的要求

```bash
# 卸载旧版 docker
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

# 设置 docker 存储库，docker 官网地址无法访问的可以使用国内其它镜像地址
curl -o /etc/yum.repos.d/docker-ce.repo https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo && sed -i 's/download.docker.com/mirrors.tuna.tsinghua.edu.cn\/docker-ce/g' /etc/yum.repos.d/docker-ce.repo

curl -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装最新版 docker 引擎和容器
yum -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 启动 docker
systemctl start docker

# 开机自启
systemctl enable docker

# 查看版本
docker -v
```

```shell
# 安装指定版本
yum list docker-ce --showduplicates | sort -r
yum install docker-ce-3:24.0.0-1.el8 docker-ce-cli-3:24.0.0-1.el8 containerd.io docker-buildx-plugin docker-compose-plugin
```

> 官方文档：https://docs.docker.com/engine/install/centos/

##### 2、ubuntu 安装 docker

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 设置 docker 存储库
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 查看版本
docker -v

# 启动 docker
service docker start
```

##### 3、配置镜像源

```bash
# 国内拉取速度过慢时可以配置镜像源来访问
tee /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": [
        "https://docker.m.daocloud.io",
        "https://docker.1panel.live",
        "https://hub.rat.dev"
    ],
    "dns": ["8.8.8.8", "8.8.4.4"]
}
EOF

# 重启 docker
systemctl daemon-reload && systemctl restart docker
```

##### 4、常用命令

```bash
# 普通用户赋予 docker 命令执行权限
usermod -aG docker guest

# 查看运行中的 docker 进程
docker ps -a

# 启动/停止/重启容器
docker start/stop/restart id/name

# 查看已安装的镜像
docker images

# 删除某个容器
docker rm id/name

# 删除某个镜像
docker rmi id/name

# 获取 Docker 对象（容器、镜像、卷、网络等）的详细信息
docker inspect id/name

# 实时显示 Docker 容器的资源使用情况
docker stats
```

**参考**

- [Docker 命令大全 \| 菜鸟教程](https://www.runoob.com/docker/docker-command-manual.html)
