---
layout: post
title: JMeter 常用 BeanShell 脚本
categories: [JMeter]
description: JMeter 常用 BeanShell 脚本
keywords: JMeter, BeanShell, Java
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

工作期间陆续记录的 JMeter 常用 beanshell 脚本。

##### 控制台打印日志

```java
log.info(name);
```

##### 生成 UUID

```java
import java.util.UUID;
UUID uuid1 = UUID.randomUUID();
vars.put("ID",(uuid1.toString()).toUpperCase().replaceAll("-",""));
```

##### 数据写入文件

```java
// 生成文件的路径
FileWriter fs=new FileWriter("C://Users//Desktop//info.csv",true); 
BufferedWriter out =new BufferedWriter(fs);

// 写入文件的参数
out.write("${telA}" + "," + "${telX}" + "," + vars.get("seqId"));
out.write(System.getProperty("line.separator"));

out.close();
fs.close();
```

##### 计算文件行数

```java
import java.io.BufferedReader;
import java.io.FileReader;

// 文件路径
String filepath = vars.get("filepath");
BufferedReader br = new BufferedReader(new FileReader(filepath));
String tmpStr = "";
int rowCount = 0;

while (tmeStr = br.readLine() != null) {
    rowCount++;
}
vars.put("rowCount", String.valueOf(rowCount));
```

##### 根据日期计算天数

```java
import java.text.*;
import java.util.Date;

// 获取变量的值
String start = vars.get("start");
String end =  vars.get("end");
Date startDate = new SimpleDateFormat("yyyy-MM-dd").parse(start);
Date endDate = new SimpleDateFormat("yyyy-MM-dd").parse(end);

// 日期转成毫秒位时间戳
long startTimeMillis = startDate.getTime();
long endTimeMillis = endDate.getTime();

// 计算天数
long timeDiffMillis = (endTimeMillis - startTimeMillis) / (24*60*60*1000) + 1;
String daysBetween = String.valueOf(timeDiffMillis);

vars.put("daysBetween", daysBetween);
```

##### 更新下次请求的值

```java
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

// 日期格式
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
// 获取变量的值
LocalDate startDate = LocalDate.parse(vars.get("start"), formatter);
LocalDate currentDate = startDate.plusDays(ctx.getThreadNum() + 1);

// 更新变量值
vars.put("start", currentDate.format(formatter));
```

##### 文件下载

```java
import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;

// 下载目录
File dir_name = new File("recordfile");
dir_name.mkdir();
// 设置日期格式
SimpleDateFormat nowtime = new SimpleDateFormat("yyyyMMddHHmmssSSS");
// 获取到上个请求返回的数据
byte[] result = prev.getResponseData();
// 以时间戳 + uuid 命名
String file_name = dir_name + File.separator + nowtime.format(new Date()) + "-" + UUID.randomUUID() + "." + vars.get("Format");
File file = new File(file_name);
FileOutputStream out = new FileOutputStream(file);
out.write(result);
out.close();
```

##### URL 参数提取

```java
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Random;
import java.net.URL;

// 读取文件路径
String filePath = vars.get("filepath");
// 打开文件
BufferedReader reader = new BufferedReader(new FileReader(filePath));
String line;
int currentLine = 0;
// 生成随机行号
Random rand = new Random();
int lineNumber = rand.nextInt(200) + 1;

// 逐行读取文件内容
while ((line = reader.readLine()) != null) {
    if (currentLine == lineNumber) {
        // 处理URL
        URL url = new URL(line);
        // 设为变量
        vars.put("recordUrl", url.toString());
        String http = url.getProtocol(); // 获取协议部分
        String ip = url.getHost(); // 获取主机 ip 部分
        int port = url.getPort();
        String voiceUrl = url.getFile(); // 获取除了 HTTP、IP 和端口之外的剩余部分
        vars.put("http", http);
        vars.put("ip", ip);
        vars.put("port", String.valueOf(port));
        vars.put("voiceUrl", voiceUrl);
        String queryString = url.getQuery(); // 获取查询字符串
        String[]params = queryString.split("&"); // 根据 & 符号拆分参数
        for (String param: params) {
            String[]keyValue = param.split("="); // 根据"="符号拆分参数名和值
            if (keyValue.length == 2 && keyValue[0].equals("id")) { // 提取 id 的值
                String value = keyValue[1];
                vars.put("id", value);
            }
        }
        break;
    }
    currentLine++;
}
// 关闭文件
reader.close();
```

##### 请求体 md5 自动加密

需手动添加 json 包到`lib\ext`目录下：[https://repo1.maven.org/maven2/org/json/json/20240303/](https://repo1.maven.org/maven2/org/json/json/20240303/)

请求 body 带有 sign 签名参数，sign 签名是根据请求 body 除去 sign 本身参数后，拼接请求参数最后 md5 加密生成的。

此处示例在 BeanShell 预处理程序先获取请求的 body，签名后给 sign 参数重新赋值，然后发送新的请求 body，因此 http 请求 body 参数中不需要写明 sign 参数，查看结果树可以看到请求 body 会带上 sign 值。

```java
import org.apache.jmeter.config.Arguments;
import org.apache.jmeter.config.Argument;
import org.json.JSONObject;
import java.util.*;
import org.apache.commons.codec.digest.DigestUtils;

Arguments arguments =  sampler.getArguments();
Argument arg = arguments.getArgument(0);
// 获取请求 body 值
String requestBody = arg.getValue();
// json 格式化
JSONObject jsonObject = new JSONObject(requestBody);

// 获取所有键并排除 sign（不使用泛型）
List keys = new ArrayList();
Iterator keyIterator = jsonObject.keys();
while (keyIterator.hasNext()) {
   String key = keyIterator.next().toString();
    // 忽略大小写排除 sign
   if (!"sign".equalsIgnoreCase(key)) {
       keys.add(key);
   }
}
Collections.sort(keys);

// 拼接参数
StringBuilder paramBuilder = new StringBuilder();
for (Object key : keys) {
   if (paramBuilder.length() > 0) {
       paramBuilder.append("&");
   }
   // 显式转为 String
   paramBuilder.append(key.toString()).append("=").append(jsonObject.get(key.toString()));
}
String paramString = paramBuilder.toString() + "&Key=" + vars.get("Key");
log.info("签名串：" + paramString);
String md5Result = DigestUtils.md5Hex(paramString).toUpperCase();
log.info("加密后：" + md5Result);
// body 添加 sign 参数
jsonObject.put("sign", md5Result);
// JSONObject 转字符串
String postData = jsonObject.toString();
// 重新赋值请求的 body 参数
arg.setValue(postData);
```

##### 请求体 md5 手动加密

```java
import org.apache.jmeter.config.Arguments;
import org.apache.jmeter.protocol.http.control.HeaderManager;
import org.apache.jmeter.protocol.http.control.Header;
import org.apache.jmeter.testelement.property.CollectionProperty;
import org.apache.commons.codec.digest.DigestUtils;

// 获取请求头
HeaderManager headers =sampler.getHeaderManager();

// 打印全部的头部内容
log.info(headers.getHeaders().getStringValue());

// 手动排序拼接请求参数
String str = "param=" + param + "&timestamp=" + timestamp + "&Key=" + key;

// md5 加密
String md5_after = DigestUtils.md5Hex(str);
log.info("\n加密前：" + str + "\n加密后：" + md5_after);

// new 一个 Header 对象
signHeader = new Header("X-sign","aaaaaaaaaaaaaaaaaa");

// 添加 Header 到请求头管理器
headers.add(signHeader);

// 打印全部的头部内容
log.info(headers.getHeaders().getStringValue());
```

##### 随机手机号码

```java
import java.util.Random;

Random random = new Random();
int suffix = random.nextInt(100000000);
String suffixStr = String.valueOf(suffix);
// 手动补零，确保后缀是 8 位
while (suffixStr.length() < 8) {
    suffixStr = "0" + suffixStr;
}
String phone = "185" + suffixStr;
log.info(phone);
```

```java
// 生成随机手机号码（13/14/15/16/17/18/19 开头）
import java.util.Random;

Random random = new Random();
String[] prefixes = {"13", "14", "15", "16", "17", "18", "19"};
String prefix = prefixes[random.nextInt(prefixes.length)];
StringBuilder phoneNumber = new StringBuilder(prefix);

// 生成剩余 9 位数字
for (int i = 0; i < 9; i++) {
    phoneNumber.append(random.nextInt(10));
}

vars.put("mobilePhone", phoneNumber.toString());
```

