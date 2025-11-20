---
layout: post
title: SVN 项目迁移到 Git 上
categories: [SVN]
description: 将 SVN 项目保留历史提交信息迁移至 git 中。
keywords: SVN, Git
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

将 SVN 项目保留历史提交信息迁移至 git 中。

在本地 SVN 代码的文件中，右键打开 Git Bash 使用以下命令获取到所有提交者的名字：

```bash 
svn log --xml | grep "^<author" | sort -u | \awk -F '<author>' '{print $2}' | awk -F '</author>' '{print $1"\r"}' > userinfo.txt
```

![image-20200311162408150](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/git/image-20200311162408150-1587635140858.png)

导出的提交人：

![image-20200311162430782](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/git/image-20200311162430782-1587635140858.png)

将要迁移的项目通过 svn clone 到本地：`git svn clone -s 项目地址 --no-metadata`

> 此处 -s 表示 svn 标准目录结构：trunk、branches、tags 的定义的项目
>
> 如果不采用标准结构，则需要如下参数：--trunk="svntrunk" --branches="svnbranches“ --tags=“svntags”

本项目非标准结构，在本地文件夹中，右键打开 Git Bash，输入命令：

```bash
 git svn clone https://192.168.0.222/svn/jsb --no-metadata --authors-file=userinfo.txt
```

历史提交信息转换完成

![image-20200311171541811](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/git/image-20200311171541811-1587635140858.png)

```bash
# 关联 GitLab 远程仓库
git remote add origin ssh://git@106.xx.xx.xxx:22222/dengtt/jsb.git

# 推送到远程仓库
git push -u origin --all
git push -u origin --tags
```

