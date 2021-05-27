---
layout: wiki
title: Jenkins
categories: jenkins
description: 记录学习 jenkins 中一些方便使用的技巧
keywords: jenkins, pipeline, linux
---

学习和使用 jenkins 过程中遇到的问题和解决办法

##### 常用插件

- 中文汉化：Chinese  
- 权限管理：Role-based Authorization Strategy
- 凭证管理：Credentials Binding
- 自定义备份 Jenkins Home 
- 目录：Backup
- git：Git
- git 分支构建支持：Git Parameter
- gitlab 的 webhook 功能支持：Gitlab Hook  Gitlab
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

##### 批量删除构建历史

在`Manage Jenkins -> Script Console`下运行以下命令

```groovy
// 项目名称
def jobName = "web_demo_pipeline"
// 删除至 maxNumber 的构建历史
def maxNumber = 30
 
Jenkins.instance.getItemByFullName(jobName).builds.findAll {
  it.number <= maxNumber
}.each {
  it.delete()
}
```

![image-20200619150800677](https://gitee.com/NineHolic/cloudimage/raw/master/jenkins/image-20200619150800677.png)

##### 离线安装插件

插件下载地址：[https://updates.jenkins-ci.org/download/plugins](https://updates.jenkins-ci.org/download/plugins)，下载离线包，点击上传进行安装

![image-20200706163221635](https://gitee.com/NineHolic/cloudimage/raw/master/jenkins/image-20200706163221635.png)

##### shell 脚本进程被杀问题

![image-20200702112856063](https://gitee.com/NineHolic/cloudimage/raw/master/jenkins/image-20200702112856063.png)

> 自 1.260 版本开始，Jenkins 默认会在构建完成后杀死构建过程中由 jenkins 中的 shell 命令触发的衍生进程ProcessTreeKiller: https://wiki.jenkins.io/display/JENKINS/ProcessTreeKiller](https://wiki.jenkins.io/display/JENKINS/ProcessTreeKiller)

**方法一**

修改配置，启动 jenkins 时禁止其杀死衍生进程：`vim /etc/sysconfig/jenkins`

在 JENKINS_JAVA_OPTIONS 中加入 `-Dhudson.util.ProcessTree.disable=true`

重启 jenkins 生效：`systemctl restart jenkins`
![image-20200703171005773](https://gitee.com/NineHolic/cloudimage/raw/master/jenkins/image-20200703171005773.png)

**方法二：**

**Pipeline：**设置 JENKINS_NODE_COOKIE 参数的值：

```groovy
withEnv(['JENKINS_NODE_COOKIE=dontkillme']) {
    sh 'sh ${tomcatHome}/bin/startup.sh'
   }
```

**非 Pipeline：**

- 在执行 shell 输入框中加入`BUILD_ID=dontKillMe` ，即可防止 jenkins 杀死启动的进程

- 临时改变 BUILD_ID 值，使得 jenkins 不会找到并结束掉 run.sh 启动的后台进程

```shell
OLD_BUILD_ID=$BUILD_ID
echo $OLD_BUILD_ID
export BUILD_ID=dontKillMe
# 执行 tomcat 启动脚本
sh ${tomcat}/bin/startup.sh
# 改回原来的 BUILD_ID 值
export BUILD_ID=$OLD_BUILD_ID
echo $BUILD_ID
```

##### node：未找到命令

使用 sonar 扫描项目时报警告：

![image-20200706170135922](https://gitee.com/NineHolic/cloudimage/raw/master/jenkins/image-20200706170135922.png)

发现服务器上未装NodeJS，但是装好后 Jenkins 内执行 shell 命令无法获取环境变量

![image-20200706165959947](https://gitee.com/NineHolic/cloudimage/raw/master/jenkins/image-20200706165959947.png)

于是搜索一番后找到原因：https://blog.csdn.net/zzusimon/article/details/57080337

（1） 可以通过`-i`参数和`-l`参数让 bash 为 login shell and interactive shell，就可以读取`/etc/profile`和`~/.bash_profile`等文件，即在 jenkins Execute Shell 里可以这么写

```shell
#!/bin/bash -ilex
...

...
```

对于 e 参数表示一旦出错，就退出当前的 shell，x 参数表示可以显示所执行的每一条命令

（2）使用流水线语法生成脚本，将需要调用 NodeJS 的 shell 命令写在括号内：

![image-20200706170928237](https://gitee.com/NineHolic/cloudimage/raw/master/jenkins/image-20200706171200545.png)

测试成功：

![image-20200706171200545](https://gitee.com/NineHolic/cloudimage/raw/master/jenkins/image-20200706170928237.png)

![image-20200706171317860](https://gitee.com/NineHolic/cloudimage/raw/master/jenkins/image-20200706171317860.png)























