---
layout: wiki
title: Jenkins
cate1: Tools
cate2: CI/CD
description: 记录学习 Jenkins 中一些方便使用的技巧
keywords: Jenkins, Linux, Skill, CI/CD
---

学习和使用 jenkins 过程中遇到的问题和解决办法

##### 常用插件

- 中文汉化：Chinese  
- 权限管理：Role-based Authorization Strategy
- 凭证管理：Credentials Binding
- 自定义备份 Jenkins Home 目录：Backup
- git：Git
- git 分支构建支持：Git Parameter
- gitlab 的 webhook 功能支持：Generic-Webhook-Trigger
- sonarqube 代码扫描：SonarQube Scanner
- 远程部署到 Tomcat：Deploy to container
- Maven 项目支持：Maven Integration
- 流水线项目支持：Pipeline
- 邮件发送：Email Extension
- NodeJS：NodeJS
- 钉钉：DingTalk
- 使 job 具备版本管理：Job Configuration History
- 构建日志上色：AnsiColor
- 自定义 Jenkins 主题：Simple Theme
- 添加侧边栏按钮链接：Sidebar Link
- 控制台输出显示构建时间：Timestamper

##### 配置反向代理

```bash
# Jenkins 启动使用自定义访问前缀
nohup java -jar jenkins.war --httpPort=7777 --prefix=/jenkins &
```

```nginx
location /jenkins {
            proxy_pass http://192.168.216.131:7777;
            proxy_set_header Host $host:$server_port;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
```

##### 批量删除构建历史

在`Manage Jenkins -> Script Console`下运行以下命令

```groovy
// 项目名称
def jobName = "web_demo_pipeline"
// 删除至 maxNumber 的构建历史
def maxNumber = 30
 
Jenkins.instance.getItemByFullName(jobName).builds.findAll {
  it.number < maxNumber
}.each {
  it.delete()
}
```

##### 工作目录迁移

在 `Manage Jenkins -> System`可以看到当前的工作目录，jenkins 将其所有数据存储在文件系统上的此目录中

![image-20231220142454711](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20231220142454711.png)

按官方说明通过环境变量方式进行更改

```bash
# 先停止 Jenkins，将默认工作目录移动到指定目录下
mv ~/.jenkins /data/

# 添加环境变量，配置 Jenkins工作目录
echo "export JENKINS_HOME=/data/.jenkins" >> ~/.bash_profile
source ~/.bash_profile

# 启动Jenkins
nohup java -jar jenkins.war --httpPort=7777 --prefix=/jenkins/ &
```

##### 版本匹配的插件

如何选择合适的插件版本进行安装，如权限插件：https://plugins.jenkins.io/role-strategy/，右侧可以看到所有版本的使用情况，按自己 jenkins 的版本搜索即可

![image-20240606162331417](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240606162331417.png)

![image-20240606162429050](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240606162429050.png)

##### 离线安装插件

插件下载地址：[https://updates.jenkins-ci.org/download/plugins](https://updates.jenkins-ci.org/download/plugins)，下载离线包，点击上传进行安装

![image-20200706163221635](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20200706163221635.png)

##### 使用 access token 拉取代码

password 填写 gitlab 的 access token

![image-20240827171836609](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240827171836609.png)

##### 查看总项目数

```groovy
// 查看总项目数
def jobs = Jenkins.instance.getAllItems()
println "Total number of jobs: ${jobs.size()}"
```

##### 项目权限管理

安装插件`Role-based Authorization Strategy`：https://plugins.jenkins.io/role-strategy/releases后重启 Jenkins，在`Manage Jenkins->Configure Global Security`下启用`Role-Based Strategy`

![Configure Security](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240606163640510.png)

先在`Manage Jenkins->Manage and Assign Roles->Manage Roles`下创建角色

**Global roles** 全局角色，主要用于配置用户的功能权限；

**Item roles：** 项目角色，主要管理项目的权限。

全局角色作用域大于项目角色，因此对控制用户仅访问特定项目时，应将 **Global roles** 的角色权限控制在最小，通过 **Item roles** 来控制项目访问

以下图为例：新加的运维角色仅勾选了 `Overall->read`，此为最基本的 Jenkins 访问权限，**Item roles** 控制仅可以对特定项目进行查看、构建操作，点击输入的 Pattern 可以查看表达式匹配到的文件夹和 job

![image-20240606163830611](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240606163830611.png)

然后在`Manage Jenkins->Manage and Assign Roles->Assign Roles`下给对应用户分配角色

该用户登录后仅可以访问 shell 脚本文件夹下的项目

![image-20240606164431084](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240606164431084.png)

![image-20240606165147823](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240606165147823.png)

##### 控制台日志输出时间

在 Manage Jenkins->Configure System 下的 Timestamper  勾选 

![image-20240109150611606](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240109150611606.png)

















