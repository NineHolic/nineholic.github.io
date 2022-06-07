---
layout: post
title: Centos7 安装 Elasticsearch
categories: Elasticsearch
description: Elasticsearch 的简单配置和使用
keywords: Elasticsearch, Linux, Centos
---

Elasticsearch 是一个高度可伸缩的开源全文搜索和分析引擎。它可以快速和接近实时地存储、搜索和分析大量数据

##### 1、安装 Elasticsearch

```shell
# 下载安装
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.12.0-x86_64.rpm
rpm -ivh elasticsearch-7.12.0-x86_64.rpm
```

修改 ES 配置文件 elasticsearch.yml：`vim /etc/elasticsearch/elasticsearch.yml`

```yaml
cluster.name: scientific-research
node.name: node-1
network.host: 192.168.0.250
http.port: 9200
cluster.initial_master_nodes: ["node-1"]
```

```shell
# 设置开机自启
systemctl enable elasticsearch.service

# 启动elasticsearch
systemctl start elasticsearch

# 查看状态
systemctl status elasticsearch

# 开放端口
firewall-cmd --zone=public --permanent --add-port=9200/tcp
firewall-cmd --reload
```

浏览器打开：http://192.168.0.250:9200，出现以下信息表示启动成功

![image-20220316170035522](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20220316170035522.png)

##### 2、安装ik分词器

下载与 ES 相同版本的 ik 分词器

```shell
# 安装 ik 分词器
cd /usr/share/elasticsearch/plugins
mkdir ik
cd ik
wget https://github.com/medcl/elasticsearch-analysis-
ik/releases/download/v7.12.0/elasticsearch-analysis-ik-7.12.0.zip
unzip elasticsearch-analysis-ik-7.12.0.zip
rm elasticsearch-analysis-ik-7.12.0.zip

# 重启服务
systemctl restart elasticsearch
```

##### 3、分词器的使用

```shell
# 使用 ES 内置分词器，只会将文字按个拆分
curl -H 'Content-Type: application/json' -XGET '192.168.0.250:9200/_analyze?pretty' -d '{"text":"飞流直下三千尺"}'

# 使用 analyzer-ik 分词器
curl -H 'Content-Type: application/json' -XGET '192.168.0.250:9200/_analyze?pretty' -d '{"analyzer":"ik_max_word","text":"飞流直下三千尺"}'
```

![image-20220316163049837](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20220316163049837.png)

```shell
# 配置自定义词库
vim /usr/share/elasticsearch/plugins/ik/config/IKAnalyzer.cfg.xml

# 增加自定义词库
echo '三千尺' > /usr/share/elasticsearch/plugins/ik/config/my.dic

# 重启 es 服务
systemctl restart elasticsearch
```

![image-20220316163012921](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20220316163012921.png)

使用自定义词库后的分词效果

![image-20220316162747400](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20220316162747400.png)

##### 4、head 插件安装

head 插件是 ES 的一个可视化管理插件，用来监视 ES 的状态，并通过 head 客户端和 ES 服务进行交互，比如创建映射、创建索引等。

安装方式见：https://github.com/mobz/elasticsearch-head

本文使用浏览器插件方式：https://chrome.google.com/webstore/detail/elasticsearch-head/ffmkiejjmecolpfloofpjologoblkegm

![image-20220316170641309](https://fastly.jsdelivr.net/gh/FlyNine/cloudimage/linux/image-20220316170641309.png)
