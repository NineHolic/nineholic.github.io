---
layout: wiki
title: Docker
cate1: Skill
cate2: Virtual
description: 记录学习 Docker 中一些方便使用的技巧
keywords: Docker, Linux, Skill, Virtual
---

##### 配置镜像源

```bash
tee /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": [
        "https://docker.m.daocloud.io",
        "https://docker.1panel.live",
        "https://hub.rat.dev"
    ]
}
EOF

systemctl daemon-reload && systemctl restart docker
```

##### 镜像导入导出

```bash
# 查看已安装的镜像
docker images

# 将镜像导出成 tar 文件，其中 docker.io/a76yyyy/qiandao:latest 可以用 image id 代替，但是恢复时 repository 和 tar 都会是 none
docker save -o qiandao.tar docker.io/a76yyyy/qiandao:latest

# 镜像文件导入
docker load -i qiandao.tar

# 压缩导出
docker save docker.io/a76yyyy/qiandao:latest | gzip > qiandao.tar.gz

# 压缩导入
gunzip -c qiandao.tar.gz | docker load
```

![image-20230618001414234](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/docker/image-20230618001414234.png)

##### 修改容器启动策略

```bash
docker update --restart=always name
```

> - no -  容器退出时，不重启容器；
> - on-failure - 只有在非 0 状态退出时才从新启动容器； 
> - always - docker 启动的时候自动启动容器，始终自动重启

##### 容器内执行 shell 脚本

```bash
# 宿主机上执行，脚本在容器内存在
docker exec test-1 /bin/bash /data/test.sh

# 获取容器内 guest 用户的 UID
docker exec test-1 id -u guest

# 以容器内 guest 用户身份执行命令
docker exec -u guest test-1 /bin/bash /data/test.sh

# 以容器内 UID 为 1000 的用户身份执行命令
docker exec -u 1000 test-1 /bin/bash /data/test.sh
```

