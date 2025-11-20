---
layout: post
title: GitHub Connection refused
categories: [GitHub]
description: GitHub 拉取代码报错
keywords: GitHub, Windows
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

解决 GitHub 拉取代码报错：`Could not read from remote repository`问题。

#### 1、问题

前几日使用 PyCharm 拉取代码时突然报错：

```bash
ssh: connect to host github.com port 22: Connection refused
Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

简单记录下排查过程

```bash
# 检查 SSH 是否能够连接成功
ssh -T git@github.com -v
```

![image-20251009104448436](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/git/image-20251009104448436.png)

可以看到请求到了本地端口，这时想起来本机用了`Steamcommunity 302`对`github.com`进行了代理，是对应的 host 失效了，使用 443 端口测试是正常的。

#### 2、解决

##### 方案一

使用 https 的 443 端口代替，本地增加 ssh 配置：`vim ~/.ssh/config`

```bash
Host github.com
    HostName ssh.github.com
	Port 443
    User git
    IdentityFile ~/.ssh/id_ed25519
```

官方说明：[https://docs.github.com/zh/authentication/troubleshooting-ssh/using-ssh-over-the-https-port](https://docs.github.com/zh/authentication/troubleshooting-ssh/using-ssh-over-the-https-port)

##### 方案二

配合使用[UsbEAm Hosts Editor](https://www.dogfight360.com/blog/18627/)工具修改 github.com host

![image-20251009110651504](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/git/image-20251009110651504.png)