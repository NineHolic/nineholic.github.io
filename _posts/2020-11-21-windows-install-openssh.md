---
layout: post
title: Windows 上安装使用 OpenSSH 服务
categories: OpenSSH
description: OpenSSH 在 Windows 上的使用
keywords: Windows, OpenSSH
---

在 Windows 上配置使用 OpenSSH 服务

##### 1、OpenSSH 简介

OpenSSH 是安全 Shell (SSH) 工具的开放源代码版本，Linux 及其他非 Windows 系统的管理员使用此类工具跨平台管理远程系统。SSH 基于客户端-服务器体系结构，用户在其中工作的系统是客户端，所管理的远程系统是服务器。 OpenSSH 包含一系列组件和工具，用于提供一种安全且简单的远程系统管理方法，其中包括：

- sshd.exe，它是远程所管理的系统上必须运行的 SSH 服务器组件
- ssh.exe，它是在用户的本地系统上运行的 SSH 客户端组件
- ssh-keygen.exe，为 SSH 生成、管理和转换身份验证密钥
- ssh-agent.exe，存储用于公钥身份验证的私钥
- ssh-add.exe，将私钥添加到服务器允许的列表中
- ssh-keyscan.exe，帮助从许多主机收集公用 SSH 主机密钥
- sftp.exe，这是提供安全文件传输协议的服务，通过 SSH 运行
- scp.exe 是在 SSH 上运行的文件复制实用工具

从 Windows 10 1809 和 Windows Server 2019 开始 Windows 开始支持 OpenSSH Server，其它版本需要额外安装

##### 2、下载 OpenSSH

本机为 windows 2016，根据不同的系统下载不同的压缩包，如果是 64 位系统，选择 32 位也可以：[https://github.com/PowerShell/Win32-OpenSSH/releases](https://github.com/PowerShell/Win32-OpenSSH/releases)，解压到 C:\Program Files 目录下，重命名为 OpenSSH，将 OpenSSH 目录加入 PATH 系统环境变量中：

![image-20201112161638698](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20201112161638698.png)

##### 3、安装 OpenSSH

```powershell
# 使用管理员运行命令提示符在本 OpenSSH 目录下安装服务
powershell.exe -ExecutionPolicy Bypass -File install-sshd.ps1

# 在防火墙入站规则中开放 22333 端口或执行以下命令，服务器安全组开放 22333 端口
netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22333

# 启动 ssh 服务，会在 C:\ProgramData\ 下生成 ssh 目录
net start sshd

# 修改 C:\ProgramData\ssh\sshd_config 文件默认端口号为 22333 后重启 ssh 服务
net stop sshd
net start sshd

# 配置开机自启 sshd 服务
sc config sshd start= auto
```

![image-20201112174718680](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20201112175015594.png)

![image-20201116152208341](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20201112174718680.png)

![image-20201112174851796](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20201116152208341.png)

##### 4、测试连接

ssh 连接成功，默认会进入 windows 的命令行下（cmd）

![image-20201112175015594](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20201116153601121.png)

可以把默认的 shell 设置为 PowerShell，以管理员运行 PowerShell 执行：

```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
```

![image-20201116153601121](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20201116154738862.png)

执行后会在注册表`HKEY_LOCAL_MACHINE\SOFTWARE\OpenSSH`下添加一条 DefaultShell 字符串值，删除后恢复为原来默认 shell，下次登陆时会进入 PowerShell 下

![image-20201116155055181](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20201116155055181.png)

也可使用 Xshell、FlashFXP 等工具进行连接，传输文件时比远程桌面直接复制更方便

##### 5、配置ssh免密登录

1)、生成SSH密钥

默认加密方式为dsa，使用参数 -t 指定 rsa 加密方式先在本地生成秘钥

![image-20201113154858419](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20201113154858419.png)

2)、将公钥上传到服务器.ssh目录下

PowerShell 中没有 ssh-copy-id 命令，手动将本地的 .ssh 目录上传到 windows 服务器用户目录下（避免文件权限问题），删除id_rsa 和 known_hosts 并将 id_rsa.pub 重命名为 authorized_keys

![image-20201116155609812](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20201116155609812.png)

3)、修改 ssh 服务的配置文件

修改服务器 C:\ProgramData\ssh 目录下的 sshd_config 文件，注释最后两行内容

若有安全级别较高可以将 PasswordAuthentication 改成 no（不允许密码登录，只能通过秘钥登录）：

```
# Match Group administrators
#       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

重启 sshd、sshd-agent 服务，并将启动类型改为自动

![image-20201116161117405](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20201116161117405.png)

使用 Xshell 测试

![image-20201116161237093](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/win/image-20201116161237093.png)
