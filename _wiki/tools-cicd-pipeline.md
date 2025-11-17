---
layout: wiki
title: Pipeline
cate1: Tools
cate2: CI/CD
description: 记录学习 Jenkins 中一些方便使用的技巧
keywords: Pipeline, Jenkins, Linux, Skill, CI/CD
---

学习和使用 jenkins pipeline 过程中遇到的问题和解决办法

##### shell 脚本进程被杀问题

![image-20200702112856063](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20200702112856063.png)

> 自 1.260 版本开始，Jenkins 默认会在构建完成后杀死构建过程中由 jenkins 中的 shell 命令触发的衍生进程ProcessTreeKiller: https://wiki.jenkins.io/display/JENKINS/ProcessTreeKiller](https://wiki.jenkins.io/display/JENKINS/ProcessTreeKiller)

**方法一**

修改配置，启动 jenkins 时禁止其杀死衍生进程：`vim /etc/sysconfig/jenkins`

在 JENKINS_JAVA_OPTIONS 中加入 `-Dhudson.util.ProcessTree.disable=true`

重启 jenkins 生效：`systemctl restart jenkins`
![image-20200703171005773](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20200703171005773.png)

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

![image-20200706170135922](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20200706170135922.png)

发现服务器上未装NodeJS，但是装好后 Jenkins 内执行 shell 命令无法获取环境变量

![image-20200706165959947](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20200706165959947.png)

于是搜索一番后找到原因：https://blog.csdn.net/zzusimon/article/details/57080337

（1） 可以通过`-i`参数和`-l`参数让 bash 为 login shell and interactive shell，就可以读取`/etc/profile`和`~/.bash_profile`等文件，即在 jenkins Execute Shell 里可以这么写

```shell
#!/bin/bash -ilex
...

...
```

对于 e 参数表示一旦出错，就退出当前的 shell，x 参数表示可以显示所执行的每一条命令

（2）使用流水线语法生成脚本，将需要调用 NodeJS 的 shell 命令写在括号内：

![image-20200706170928237](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20200706171200545.png)

测试成功：

![image-20200706171200545](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20200706170928237.png)

![image-20200706171317860](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20200706171317860.png)

##### 构建超时自动停止

在 pipeline 设置超时时间，超过该限制时会中断 pipeline 的执行

```groovy
// 方式一：在 pipeline 中配置
pipeline {
  options{
        timeout(time:15, unit:'SECONDS')
  }
  stages { .. }
  // ..
}


// 方式二：在 stage 中配置
pipeline {
    agent any
    stages {
        stage('Run') {
            steps {
                retry(3) {
                    sh './deploy.sh'
                }
 
                timeout(time: 3, unit: 'MINUTES') {
                    sh './ren_test.sh'
                }
            }
        }
    }
```

maven 类型项目在构建环境下配置，勾选 Abort the build if it’s stuck

![image-20240116143326726](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240116143326726.png)

##### 在 pipeline 中触发其他 job

在项目构建前需要先构建项目 test-common，可以在 pipeline 进行配置

```groovy
// 放在 stages 下，变量用双引号
        stage('ltprivate-center-common') {
            steps {
                timeout(time: 30, unit: 'SECONDS') {
                    script{
                        echo "正在构建 test-common, 分支：${params.branch}"
                        build job :'test-common', parameters:[string(name: 'branch', value: "${params.branch}")]
                        echo "完成构建"
                    }
                }
            }
        }
```

##### when 指令的使用

`when` 指令位于stage指令中，允许 pipeline 根据给定的条件决定是否应该执行阶段，必须包含至少一个条件

例：`buildType`为`Choice Parameter`参数，当选择 deploy 进行构建时，只会执行满足条件的 stage 

```groovy
pipeline {
    agent any
    stages {
        stage('更新') {
            when { environment name: 'buildType', value: 'deploy' }
            steps {
                echo "更新完成"
            }
        }
        stage('回滚') {
            when { environment name: 'buildType', value: 'rollback' }
            steps {
                echo "回滚更新完成"
            }
        }
    }
}
```

控制台输出

```html
Started by user admin
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] node
Running on Jenkins in /data/.jenkins/workspace/测试目录/webhook-common
[Pipeline] {
[Pipeline] stage
[Pipeline] { (更新)
Stage "更新" skipped due to when conditional
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (回滚)
[Pipeline] echo
回滚更新完成
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```

> 其它使用条件
>
> **changelog**: `when { changelog '.*^\\[DEPENDENCY\\] .+$' }`，构建的SCM变更日志包含一个给定的正则表达式模式，则执行该阶段
>
> **anyOf**：`when { anyOf { branch 'master'; branch 'staging' } }`，当至少有一个嵌套条件为 `true` 时执行，必须包含至少一个条件
>
> https://blog.csdn.net/a772304419/article/details/132456478

##### input 指令的使用

input 允许用户在执行各个 stage 时由人工确认是否继续进行，官网 input 语法：https://www.jenkins.io/doc/book/pipeline/syntax/#input，input 书写方式有以下两种

- message 呈现给用户的提示信息
- id 可选，默认为stage名称
- ok 默认表单上的 ok 文本
- submitter 可选，以逗号分隔的用户列表或允许提交的外部组名。默认允许任何用户
- submitterParameter 环境变量的可选名称。如果存在，用submitter 名称设置
- parameters 提示提交者提供的一个可选的参数列表

**方式一**

input 与 steps 同级

```groovy
pipeline {
    agent any
    stages {
        stage('更新') {
            when { environment name: 'buildType', value: 'deploy' }
            steps {
                echo "更新完成"
            }
        }
        stage('回滚') {
            when { 
                beforeInput false
                environment name: 'buildType', value: 'rollback' 
            }
            input {
                message "是否继续回退更新？"
                ok "继续"
                parameters {
                    string(name: 'history_number', defaultValue: 'lastVersion', description: '请输入回退更新的历史构建编号，回退到上个版本使用：lastVersion')
                }
            }
            steps {
                script {
                    echo "history_number: ${env.history_number}，回滚完成"
                }
            }
        }
    }
}
```

> PS：当 when 和 input 同时使用时需要在 when 内增加`beforeInput true`，此时`when` 条件将首先计算，只有当条件计算为 true 时才会进入`input`，默认情况下 beforeInput 为 false
>
> 以上述流水线为例，beforeInput 为 false，input 会在 when 之前执行，因此选择 deploy 构建时，流水会卡在 input 处
>
> ![image-20240129103102950](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240129103102950.png)

**方式二**

input 在 steps 内部

```groovy
pipeline {
    agent any
    stages {
        stage('更新') {
            when { environment name: 'buildType', value: 'deploy' }
            steps {
                echo "更新完成"
            }
        }
        stage('回滚') {
            when { environment name: 'buildType', value: 'rollback' }
            steps {
                script {
                    timeout(time: 5, unit: 'SECONDS') {
                        def inputResult = input message: "是否继续回退更新？", ok: "继续", parameters: [
                            string(name: 'history_number', defaultValue: 'lastVersion', description: '请输入回退更新的历史构建编号，回退到上个版本使用：lastVersion')
                        ]
                    }
                    echo "history_number: ${inputResult}，回滚完成"
                }
            }
        }
    }
}
```

##### 构建失败时通知

使用企业微信机器人通知，官网 post 语法：https://www.jenkins.io/doc/book/pipeline/syntax/#post

![image-20240116144228521](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240116144228521.png)

```groovy
pipeline {
    agent any    
    stages {
        stage('检出') {
            steps {
                script{
                    // 将当前构建结果设置为失败
                    currentBuild.result = "FAILURE"
                }
            }
        }
    }
	post{
        // success{}
        // 构建失败时发送通知
        failure{
            sh '''curl -s -H "Content-Type: application/json" -X POST -d \'{
				"msgtype": "markdown",
				"markdown": {
				 "content": "<font color=\\"warning\\">**Jenkins任务通知**</font> \\n
				 >构建编号：<font color=\\"comment\\">\'"${BUILD_DISPLAY_NAME}"\'</font>
				 >任务名称：<font color=\\"comment\\">\'"${JOB_BASE_NAME}"\'</font>
				 >构建分支：<font color=\\"comment\\">\'"${branch}"\'</font>
				 >构建状态：<font color=\\"comment\\">Failure</font>"
				}
			}\' \'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx\''''
        }
	}
}
```

##### Generic Webhook Trigger 配置

![image-20240109151457785](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240109151457785.png)

过滤条件：仅当 test-admin目录下的文件被 push 时，触发构建

![image-20240109151555424](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/jenkins/image-20240109151555424.png)

> 修改默认触发时间：https://www.cnblogs.com/huandada/p/13067778.html

