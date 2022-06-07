---
layout: post
title: Centos7 下安装配置 Gitlab
categories: Gitlab
description: Gitlab 的安装与简单配置
keywords: Linux, Centos, Gitlab
---

Centos7 下 Gitlab 的安装配置与备份恢复

##### 1、Gitlab 介绍

GitLab 是利用 Ruby on Rails 一个开源的版本管理系统，实现一个自托管的 Git 项目仓库，可通过 Web 界面进行访问公开的或者私人项目。

GitLab 能够浏览源代码，管理缺陷和注释。可以管理团队对仓库的访问，它非常易于浏览提交过的版本并提供一个文件历史库。团队成员可以利用内置的简单聊天程序 (Wall) 进行交流。

它还提供一个代码片段收集功能可以轻松实现代码复用，便于日后有需要的时候进行查找

**Gitlab 服务构成**

- Nginx：静态 web 服务器
- gitlab-shell：用于处理 Git 命令和修改 authorized keys 列表
- gitlab-workhorse: 轻量级的反向代理服务器
- logrotate：日志文件管理工具
- postgresql：数据库
- redis：缓存数据库
- sidekiq：用于在后台执行队列任务（异步执行）
- unicorn：An HTTP server for Rack applications，GitLab Rails 应用是托管在这个服务器上面的

**gitlab-ee 和 gitlab-ce 的区别**
关于 gitlab-ee（企业版）和 gitlab-ce（社区版），二者是基于同样的核心代码进行开发，只是 gitlab-ee 功能更强大，但需要付费使用，有 30 天试用期。但试用期过后如果不付费，它就跟 gitlab-ce 功能是完全一样的，只是需要付费的功能无法再继续使用而已。

##### 2、安装 Gitlab

安装要求：[https://docs.gitlab.com/ee/install/requirements.html](https://docs.gitlab.com/ee/install/requirements.html)

```shell
# 安装依赖
yum install -y curl policycoreutils-python openssh-server perl

# 启动ssh
systemctl enable sshd
systemctl start sshd

# 将http和https加入防火墙策略，并重启防火墙。
systemctl start firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
systemctl reload firewalld
systemctl enable firewalld

# 安装 postfix 发邮件功能，若使用外部 SMTP 服务器发送邮件可以不必安装
yum install -y postfix
systemctl enable postfix
systemctl start postfix
```

- 离线安装

  rpm 镜像：[https://packages.gitlab.com/gitlab/gitlab-ee](https://packages.gitlab.com/gitlab/gitlab-ee)

  ```shell
  # 下载安装 rpm 包，本机为 centos7
  wget --content-disposition https://packages.gitlab.com/gitlab/gitlab-ee/packages/el/7/gitlab-ee-14.6.0-ee.0.el7.x86_64.rpm/download.rpm
  
  rpm -ivh gitlab-ee-14.6.0-ee.0.el7.x86_64.rpm
  ```

- 在线安装

  ```shell
  # 配置 gitlab-ce 的 yum 库
  curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
  
  # 在线安装gitlab-ee
  yum install -y gitlab-ee
  
  # 如果要安装指定的版本，在后面填上版本号即可
  yum install -y gitlab-ee-14.6.0
  ```

##### 3、修改配置

修改 Gitlab 主配置文件：`vim /etc/gitlab/gitlab.rb`

在 vim 下输入`/关键字` 快速查找，按 n 键查找下一个

```yaml
# 改为需要配置的域名或 IP，内网则为本机 IP
external_url 'http://192.168.0.250'

# 修改监听端口，默认 80
nginx['listen_port'] = 22333

# ssh 地址配置，端口保持与 ssh 登录端口一致
gitlab_rails['gitlab_ssh_host'] = '192.168.0.250'
gitlab_rails['gitlab_shell_ssh_port'] = 30001

# Email 设置
gitlab_rails['gitlab_email_enabled'] = true
gitlab_rails['gitlab_email_from'] = 'xxx@qq.com'      # 自己的邮箱
gitlab_rails['gitlab_email_display_name'] = 'Name'    # gitlab 给你发邮件时使用的名字。
```

以下配置按需修改

```yaml
# 若未安装 postfix，则需要配置 smtp
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.qq.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "xxxx@qq.com"
gitlab_rails['smtp_password'] = "xxxxxxxxxxx"
gitlab_rails['smtp_domain'] = "qq.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false

# 关闭普罗米修斯监控（内存低时可以关闭节省资源）
prometheus['enable'] = false
prometheus['monitor_kubernetes'] = false
```

>- /etc/gitlab/gitlab.rb：主配置文件，包含外部URL、仓库目录、备份目录等
>- /etc/gitlab/gitlab-secrets.json：（执行gitlab-ctl reconfigure命令行后生成），包含各类密钥的加密信息
>- smtp 邮件服务商配置：[https://docs.gitlab.com/omnibus/settings/smtp.html](https://docs.gitlab.com/omnibus/settings/smtp.html)

```shell
# 重新应用 gitlab 的配置，每次修改/etc/gitlab/gitlab.rb 文件之后执行
gitlab-ctl reconfigure

# 查看初始密码
cat /etc/gitlab/initial_root_password

# 或者直接重置密码，此命令从 13.9 版本后可用
gitlab-rake "gitlab:password:reset"

# 开放端口
firewall-cmd --zone=public --permanent --add-port=22333/tcp
firewall-cmd --reload

# 查看状态
gitlab-ctl status
```

![image-20220404235024738](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/git/image-20220404235024738.png)

安装完成后建议关闭注册功能

##### 4、Gitlab 备份

默认备份目录：`/var/opt/gitlab/backups`

修改 gitlab 配置文件：`vim /etc/gitlab/gitlab.rb`

```shell
# 指定备份后数据存放的路径、权限、时间配置
gitlab_rails['manage_backup_path'] = true                  #292行      开启备份功能
gitlab_rails['backup_path'] = "/gitlab_backup"         #293行      指定备份的路径
gitlab_rails['backup_archive_permissions'] = 0644          #296行      备份文件的权限
gitlab_rails['backup_keep_time'] = 604800                  #301行      备份保留时间（保留7天）
```

```shell
# 创建备份目录并授权
mkdir /gitlab_backup
chown -R git:root /gitlab_backup/

# 重新生效 gitlab 配置
gitlab-ctl reconfigure

# 手动备份
gitlab-rake gitlab:backup:create

# 定时备份
0 3 * * * /opt/gitlab/bin/gitlab-rake gitlab:backup:create >> /gitlab_backup/crontab.log 2>&1
```

##### 5、Gitlab 恢复

**只能还原到与备份文件相同的 gitlab 版本**

```shell
# 下载安装与备份相同版本的 gitlab
wget --content-disposition https://packages.gitlab.com/gitlab/gitlab-ee/packages/el/7/gitlab-ee-13.10.3-ee.0.el7.x86_64.rpm/download.rpm

rpm -ivh gitlab-ee-13.10.3-ee.0.el7.x86_64.rpm

# 参考上述安装修改配置
vim /etc/gitlab/gitlab.rb
gitlab-ctl reconfigure

# 停止相关数据连接服务
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq

# 将备份文件放在相应的备份路径下
mv 1618907900_2021_04_20_13.10.3-ee_gitlab_backup.tar /var/opt/gitlab/backups/
chmod 777 1618907900_2021_04_20_13.10.3-ee_gitlab_backup.tar

# gitlab 的恢复操作会先将当前所有的数据清空
gitlab-rake gitlab:backup:restore BACKUP=1618907900_2021_04_20_13.10.3-ee
```

![image-20220317225958638](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/git/image-20220317225958638.png)

```shell
# 重启 gitlab
gitlab-ctl restart

# 恢复命令完成后，可以 check 检查一下恢复情况
gitlab-rake gitlab:check SANITIZE=true
```

其它命令

```shell
# 日志目录：/var/log/gitlab
# 查看 nginx 访问日志
gitlab-ctl tail nginx/gitlab_acces.log	

# 查看 postgresql 日志
gitlab-ctl tail postgresql

# 查看所有服务
gitlab-ctl service-list

# 检查配置并启动
gitlab-ctl check-config
```

##### 6、其他

**修改 root 密码**

```shell
# 直接重置密码，此命令从 13.9 版本后可用
gitlab-rake "gitlab:password:reset"

# 进控制台修改
gitlab-rails console -e production
user.password = 'new_password'
user.password_confirmation = 'new_password'
user.save!
exit
```

- [https://docs.gitlab.com/ee/security/reset_user_password.html#use-a-rails-console](https://docs.gitlab.com/ee/security/reset_user_password.html#use-a-rails-console)

**添加SSL认证**

参考 https://blog.csdn.net/qq_43626147/article/details/109160229

**Gitlab 管理页面保存后报 500 错误**

首先，遍历数据库中所有可能的加密值，验证它们是否可使用 gitlab-secrets.json解密。

```shell
gitlab-rake gitlab:doctor:secrets
```

![image-20211230095708439](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/git/image-20211230095708439.png)

```shell
gitlab-rails dbconsole
```

```sql
-- Clear project tokens
UPDATE projects SET runners_token = null, runners_token_encrypted = null;

-- Clear project tokens
UPDATE projects SET runners_token = null, runners_token_encrypted = null;
-- Clear group tokens
UPDATE namespaces SET runners_token = null, runners_token_encrypted = null;
-- Clear instance tokens
UPDATE application_settings SET runners_registration_token_encrypted = null;
-- Clear key used for JWT authentication
-- This may break the $CI_JWT_TOKEN job variable:
-- https://gitlab.com/gitlab-org/gitlab/-/issues/325965
UPDATE application_settings SET encrypted_ci_jwt_signing_key = null;
-- Clear runner tokens
UPDATE ci_runners SET token = null, token_encrypted = null;

-- truncate web_hooks table
TRUNCATE web_hooks CASCADE;
```

**参考**

- [Doctor Rake tasks](https://docs.gitlab.com/ee/administration/raketasks/doctor.html#verify-database-values-can-be-decrypted-using-the-current-secrets)
- [Reset runner registration tokens](https://docs.gitlab.com/ee/raketasks/backup_restore.html#reset-runner-registration-tokens)
- [Issue-26171](https://gitlab.com/gitlab-org/gitlab/-/issues/26171)
- [Gitlab的安装及使用](https://www.cnblogs.com/hgzero/p/14088215.html)
