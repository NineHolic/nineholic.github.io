---
layout: post
title: 内网下使用 Nginx 转发邮件
categories: [Nginx]
description: 内网邮件转发
keywords: Nginx
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

内网邮件通过 Nginx 代理进行转发。

![image-20220325133718280](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/nginx/image-20220325133718280.png)

##### 1、安装 stream

使用 stream 方式代理 smtp 协议的邮件服务，需安装 stream 模块

```shell
# 查看已安装模块
./nginx -V

# 编译时需加上 stream 模块
./configure --prefix=/usr/local/nginx --with-stream ...
make && make install
```

##### 2、nginx 配置

```nginx
stream {
    # 邮件转发
    server {
        listen 8765;
        proxy_connect_timeout 5s;
        proxy_timeout 5s;
        proxy_pass smtp.qq.com:587;
    }
}
```

##### 3、内网测试邮件发送

![image-20220325140602124](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/nginx/image-20220325140602124.png)
