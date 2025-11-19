---
layout: post
title: JMeter 常用函数
categories: [JMeter ]
description: JMeter 常用函数
keywords: JMeter, functions
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

JMeter 官网说明：[https://jmeter.apache.org/usermanual/functions.html](https://jmeter.apache.org/usermanual/functions.html)

#### 1、内置函数方法

##### 时间格式化

```bash
# 北京时间 utc+8
${__time(YMD,)}                            # 20180121
${__time(yyyyMMddHHmmss)}                  # 20221012174329
${__time(YYYY-MM-dd HH:mm:ss,time)}        # 2022-10-12 17:43:29
${__time(YYYY-MM-dd HH:mm:ss.SSS,time)}    # 2022-10-12 17:43:29.999

# 日期格式化：20180121 -> 2018-01-21
${__dateTimeConvert(20180121,yyyyMMdd,yyyy-MM-dd,)}

# 当前时间 +20s，PT10m：+10 分钟，PT1H：+1 小时，P1d：+1 天，P1dT1H10m20s：+1 天 1 小时 10 分钟 20 秒
${__timeShift(yyyy-MM-dd HH:mm:ss,,PT20S,,)}
```

##### 时间戳

```bash
# 13 位时间戳：1665566580027
${__time(,)}

# 10 位时间戳：1665566580
${__time(/1000,)}
```

##### uuid

```bash
// uuid：fea9aafd-e03e-4682-9f35-878c4381fb91
${__UUID}
```

##### 随机手机号码

```bash
# 11 位随机号码
139${__RandomString(8,0123456789,)}

# num1、num2 等分别为号码前缀变量
${__RandomFromMultipleVars(num1|num2|num3|num4|num5,)}${__RandomString(8,0123456789,)}

# 手机号截取最后两位
${__groovy(vars.get('mobile')[-2..-1],)}
```

##### 计数器

```bash
# 计数器
${__counter(,)}
```

##### 加减法

```bash
# 整数相加得到变量 var，值为 3，相减用负号实现
${__intSum(2,1,var)}
```

##### 参数拼接

```bash
# 普通拼接：businessNumber_1、businessNumber_2 等
businessNumber_${num}

# 变量拼接：${businessNumber_1}、${businessNumber_2} 等
${__V(businessNumber_${num})}
```

#### 2、Groovy 方法

```bash
# 乘法，不支持小数
${__groovy(2*1000)}
```

