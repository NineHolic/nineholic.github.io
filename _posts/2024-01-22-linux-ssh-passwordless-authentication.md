---
layout: post
title: Linux 配置免密登录
categories: [Linux]
description: SSH 免密登录配置
keywords: Linux, Centos, Ubuntu
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

使用非对称加密算法制作一对密钥（公钥、私钥），将公钥添加到服务器的某个账户上，然后在客户端利用私钥即可完成认证并登录，公钥存在服务器，私钥存在本地计算机，私钥不在网络传输，降低被黑客截获风险。

##### 1、配置密钥

配置服务器  192.168.216.128 免密登录  192.168.216.129

- 服务器 192.168.216.128 上使用`ssh-keygen`命令生成密钥，`-t`未指定参数时默认的密钥加密方法是 RSA

```shell
# 使用 ED25519 加密方式生成密钥，若有设置 passphrase，则 ssh 登录时还需要输入密钥的密码
ssh-keygen -t ed25519

# 将公钥写入到服务器 192.168.216.129 的 ~/.ssh/authorized_keys 文件中（文件不存在会自动创建），执行后需要输入密码
ssh-copy-id -p 22333 guest@192.168.216.129
```

> 指定密钥名称：`ssh-keygen -t ed25519 -f ~/.ssh/test` 
>
> 指定密钥文件：`ssh-copy-id -i ~/.ssh/test.pub guest@192.168.216.129`
>
> 使用密钥登录：`ssh -i ~/.ssh/test root@192.168.216.129`

- 本地可以使用 Xshell 生成密钥：工具 -> 用户密钥管理者

![image-20240122100348599](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20240122100348599.png)

将公钥手动写入远程机器的`~/.ssh/authorized_keys`文件中

```shell
# 目录和文件不存在就手动创建，注意目录和文件权限
mkdir ~/.ssh && chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
vim ~/.ssh/authorized_keys
```

##### 2、测试登录

```shell
# 测试免密登录
ssh root@192.168.216.129

# 使用指定密钥连接，注意私钥权限应为 600
ssh -i ~/.ssh/id_ed25519_256-51 -p 22333 root@192.168.216.129
```

![image-20240122110254517](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20240122110254517.png)

##### 3、问题

配置后免密登录仍未生效时，可以查看服务器日志信息排查问题：`tail -f /var/log/secure`

通过 RSA 密钥远程连接服务器时，提示登录失败，sshd 日志提示

```html
userauth_pubkey: signature algorithm ssh-rsa not in PubkeyAcceptedAlgorithms [preauth]
```

> 解决方案：使用 ECDSA 或者 ED25519 等其他加密方式
>
> ssh-rsa 签名算法是 SHA1 的哈希算法和 RSA 公钥算法的结合使用，由于目前 SHA1 的哈希算法容易受到攻击，OpenSSH 从 8.7 以后版本开始默认不支持 ssh-rsa 签名的方式，因此使用 RSA 生成的密钥配置免密登录时有以下错误

##### 4、其它

配置完成后可以关闭服务器密码登录：`vim /etc/ssh/sshd_config`

```bash
# 禁止密码登录
PasswordAuthentication no

# 重启 SSH 服务
service sshd restart
```

