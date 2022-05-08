---
layout: post
title: Centos7 下静默安装 Oracle 11g
categories: [Oracle, Linux, Centos]
description: 初次在 linux 上安装 Oracle 11g，记录安装过程和之后补充的一些知识
keywords: Oracle, Linux, Centos
---

Centos 7 下静默安装 Oracle 11g，安装环境：Centos 7.8、JDK 1.8、Oracle 11.2.0.1

#### 一、安装 Oracle

Oracle 11.2.0.1 官网下载地址：

[http://download.oracle.com/otn/linux/oracle11g/R2/linux.x64_11gR2_database_1of2.zip](http://download.oracle.com/otn/linux/oracle11g/R2/linux.x64_11gR2_database_1of2.zip)
[http://download.oracle.com/otn/linux/oracle11g/R2/linux.x64_11gR2_database_2of2.zip](http://download.oracle.com/otn/linux/oracle11g/R2/linux.x64_11gR2_database_2of2.zip)

##### 1、安装依赖

使⽤ root ⽤户执⾏，直接安装以下依赖包

- The following or later version of packages for Oracle Linux 7, and Red Hat Enterprise Linux 7 must be installed:

```shell
yum -y install binutils compat-libcap1 compat-libstdc++-33 compat-libstdc++-33*i686 compat-libstdc++-33*.devel compat-libstdc++-33 compat-libstdc++-33*.devel gcc gcc-c++ glibc glibc*.i686 glibc-devel glibc-devel*.i686 ksh libaio libaio*.i686 libaio-devel libaio-devel*.devel libgcc libgcc*.i686 libstdc++ libstdc++*.i686 libstdc++-devel libstdc++-devel*.devel libXi libXi*.i686 libXtst libXtst*.i686 make sysstat unixODBC unixODBC*.i686 unixODBC-devel unixODBC-devel*.i686 unzip vim
```

> 参考官方：http://docs.oracle.com/cd/E11882_01/install.112/e24326/toc.htm#BHCCADGD

##### 2、⽤户和组准备

使⽤ root ⽤户执⾏

```shell
# 数据库安装组
groupadd oinstall

# 数据库管理员组
groupadd dba
 
# -g 表示为用户指定一个主 group，-G 表示为用户指定一个副 group，平时主要是 oinstall 组发生作用
useradd -g oinstall -G dba -d /home/oracle oracle

# 为管理员用户 oracle 设置密码
passwd oracle
```

![image-20200325223330655](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200318232522415.png)

##### 3、⽬录准备及权限调整

使⽤ root ⽤户执⾏

```shell
# 数据库系统安装⽬录
mkdir -p /home/oracle/app/oracle

# 数据库数据安装⽬录 
mkdir -p /home/oracle/app/oracle/data/oradata

# 数据备份⽬录 
mkdir -p /home/oracle/app/oracle/data/oradata_back

# 清单⽬录 
mkdir /home/oracle/inventory

chown -R oracle:oinstall /home/oracle/app/oracle
chown -R oracle:oinstall /home/oracle/inventory
chown -R oracle:oinstall /home/oracle/app/oracle/data
chmod -R 775 /home/oracle/app/oracle
chmod -R 775 /home/oracle/app/oracle/data
```

##### 4、内核参数调整

使⽤ root ⽤户执⾏：`vim /etc/sysctl.conf`

```shell
# 在⽂件最后新增: 
fs.aio-max-nr = 1048576 
fs.file-max = 6815744 
kernel.shmall = 2097152 
kernel.shmmax = 2147483648 
kernel.shmmni = 4096 
kernel.sem = 250 32000 100 128 
net.ipv4.ip_local_port_range = 9000 65500 
net.core.rmem_default = 262144 
net.core.rmem_max = 4194304 
net.core.wmem_default = 262144 
net.core.wmem_max = 1048586
```

使之⽣效：`/sbin/sysctl -p`

##### 5、⽤户的限制⽂件修改

要改善 Linux 系统上的软件性能，必须对 Oracle 软件所有者用户（grid、oracle）增加以下资源限制

使⽤ root ⽤户执⾏：`vim /etc/security/limits.conf`

```shell
# 在最后新增: 
oracle           soft    nproc           2047
oracle           hard    nproc           16384
oracle           soft    nofile          1024
oracle           hard    nofile          65536
oracle           soft    stack           10240
```

```shell
Shell 限制    limits.conf 中的条目      硬限制
打开文件描述符的最大数      nofile   65536
可用于单个用户的最大进程数   nproc   16384
进程堆栈段的最大大小        stack  10240
```

修改文件：`vim /etc/pam.d/login`

```shell
# 在最后新增: 
session  required   /lib64/security/pam_limits.so
session  required   pam_limits.so
```

对默认的 shell 启动文件进行以下更改，以便更改所有 Oracle 安装所有者的 ulimit 设置：

`vim /etc/profile`

```shell
# 在最后新增: 
if [ $USER = "oracle" ]; then 
 if [ $SHELL = "/bin/ksh" ]; then   
   ulimit -p 16384   
   ulimit -n 65536 
 else   
   ulimit -u 16384 -n 65536 
 fi 
fi
```

使之⽣效：`source /etc/profile`

##### 6、环境配置

使用 root 用户执行

修改主机名，本机改为 DB：`vim /etc/hostname`

添加主机名与 IP 对应记录：`vim /etc/hosts`

```
192.168.33.131	DB
```

禁用 selinux，将 SELINUX=enforcing 改为 SELINUX=disabled 后重启服务器：`vim /etc/selinux/config`

![image-20200318232522415](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200325223330655.png)

```shell
# 重启后查看 SELinux 状态（enabled 即为开启状态）
/usr/sbin/sestatus -v

# 开放 1521 端口
firewall-cmd  --zone=public --add-port=1521/tcp --permanent

# 重启防火墙
firewall-cmd --reload
```

![image-20200325223422821](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200325223422821.png)

使⽤ oracle ⽤户执⾏：`su - oracle`

`vim ~/.bash_profile`

```shell
# 在最后新增如下，注意其中的 ORACLE_BASE 和 ORACLE_HOME 也在应答⽂件中有设置，要保持⼀致 
export LANG=en_US.UTF-8
export ORACLE_BASE=/home/oracle/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11gr2/dbhome_1
export ORACLE_SID=orcl
PATH=/usr/sbin:$PATH:$ORACLE_HOME/bin
export PATH
```

使之⽣效：`source ~/.bash_profile`

##### 7、使用应答⽂件静默安装 oracle

使⽤ oracle ⽤户下执⾏：`su - oracle`

```shell
# 解压安装包后得到⼀个 database 的⽂件夹 
unzip linux.x64_11gR2_database_1of2.zip 
unzip linux.x64_11gR2_database_2of2.zip

# 在复制的 demo 应答⽂件基础上修改 
cp /home/oracle/response/db_install.rsp /home/oracle/database/response/my_db_install.rsp
```

| 文件             | 作用                                                         |
| ---------------- | ------------------------------------------------------------ |
| db_install.rsp   | 静默安装 Oracle Database 11g，安装应答                       |
| grid_install.rsp | 静默安装 Oracle Grid Infrastructure                          |
| dbca.rsp         | 静默安装 Database Configuration Assistant，创建数据库应答    |
| netca.rsp        | 静默安装 Oracle Net Configuration Assistant，建立监听、本地服务名等网络设置的应答 |

部分参数说明，按需修改：`vim /home/oracle/response/my_db_install.rsp`

```ini
# 安装类型：INSTALL_DB_SWONLY（只装数据库软件）、INSTALL_DB_AND_CONFIG（安装并配置数据库）、UPGRADE_DB（更新数据库）
oracle.install.option=INSTALL_DB_SWONLY

# 主机名称（命令 hostname 查询）
ORACLE_HOSTNAME=DB

# 安装组
UNIX_GROUP_NAME=oinstall

# 指定 INVENTORY 目录
INVENTORY_LOCATION=/home/oracle/inventory

# 指定查询语言
SELECTED_LANGUAGES=en，zh_CN

# oracle_home 路径根据目录情况注意修改
ORACLE_HOME=/home/oracle/app/oracle/product/11gr2/dbhome_1

# oracle_base 路径根据目录情况注意修改
ORACLE_BASE=/home/oracle/app/oracle

# oracle 版本：EE：企业版 (Enterprise Edition)、SE：标准版 (Standard Edition)
# SEONE：标准版第二版 (Standard Edition One)、PE：个人版 (Personal Edition) 仅 windows 系统有

oracle.install.db.InstallEdition=EE

# 自定义安装，否，使用默认组件
oracle.install.db.isCustomInstall=false

# dba 用户组
oracle.install.db.DBA_GROUP=dba

# oper 用户组
oracle.install.db.OPER_GROUP=dba

# 数据库类型     
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=orcl

# 此处注意与环境变量内配置 SID 一致
oracle.install.db.config.starterdb.SID=orcl

# 通常中文选择的有 ZHS16GBK 简体中文库，建议选择 unicode 的 AL32UTF8 国际字符集
oracle.install.db.config.starterdb.characterSet=AL32UTF8

# 指定 Oracle 自动管理内存的大小，最小是 256MB
oracle.install.db.config.starterdb.memoryLimit=1500

# 是否启用安全设置
oracle.install.db.config.starterdb.enableSecuritySettings=true

# 设定所有数据库用户使用同一个密码，其它数据库用户就不用单独设置了
oracle.install.db.config.starterdb.password.ALL=ora1234!

# 数据库本地管理工具 DB_CONTROL，远程集中管理工具 GRID_CONTROL
oracle.install.db.config.starterdb.control=DB_CONTROL

# 设置自动备份
oracle.install.db.config.starterdb.automatedBackup.enable=false
# 自动备份会启动一个 job，指定启动 job 的系统用户 ID
oracle.install.db.config.starterdb.automatedBackup.osuid=
# 自动备份会开启一个 job，需要指定 OSUser 的密码
oracle.install.db.config.starterdb.automatedBackup.ospwd=
# 自动备份使用的文件系统存放数据库文件还是 ASM
oracle.install.db.config.starterdb.storageType=
# 使用文件系统存放数据库文件才需要指定备份恢复目录
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=

# 禁用安全更新
DECLINE_SECURITY_UPDATES=true
```

开始安装前先检查 swap 内存大小和磁盘大小是否够用，不够的话需要增加 swap 大小和磁盘，详见文章底部

![image-20200510211959538](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200510211959538.png)

```shell
# 注意：重装 Oracle 时执⾏前 /home/oracle/inventory 下不能有内容， 否则会报错 [INS-32035]， 重装的时候要清空此⽬录
rm -rf /home/oracle/inventory/*

# 执⾏安装
/home/oracle/database/runInstaller -silent -debug -force -responseFile /home/oracle/database/response/my_db_install.rsp
```

执⾏一段时间后提示需要 root ⽤户执⾏两个脚本时，即为安装成功：

![image-20200325223920792](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200325223920792.png)

使⽤ root ⽤户执⾏两个脚本

```shell
/home/oracle/inventory/orainstRoot.sh
/home/oracle/app/oracle/product/11gr2/dbhome_1/root.sh
```

![image-20200325222300814](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200325222300814.png)

##### 8、使用数据库应答文件创建数据库

使⽤ oracle ⽤户执⾏：`su - oracle`

```shell
# 在 demo 应答⽂件基础上修改 
cp /home/oracle/database/response/dbca.rsp /home/oracle/database/response/my_dbca.rsp
```

修改应答⽂件中的内容：`vim /home/oracle/database/response/my_dbca.rsp`

```ini
# 创建数据库
OPERATION_TYPE = "createDatabase" 

# 全局数据库名称
GDBNAME = "orcl11g"

# 数据库实例 SID
SID = "orcl" 

# sys 用户的密码
SYSPASSWORD = "ora1234!" 

# system 用户的密码
SYSTEMPASSWORD = "ora1234!"

# 数据文件位置
DATAFILEDESTINATION = /home/oracle/app/oracle/data/oradata

# 恢复区位置
RECOVERYAREADESTINATION = /home/oracle/app/oracle/data/oradata_back

# 可选 
SYSDBAUSERNAME = "system" 
SYSDBAPASSWORD = "ora1234!" 

INSTANCENAME = "orcl11g"

# 数据库的字符集，按需求设置，ZHS16GBK 采用 2 个字符存储，而 AL32UTF8 采用 3-4 个字符存储，效率不同
# AL32UTF8 是 utf8 字符集，适用于中文、韩语、日语等等不同的语言使用
# ZHS16GBK 是中文字符集，只能存储中文和英文字符，存储韩文则显示为乱码（没有编码）
CHARACTERSET = "AL32UTF8"

# 数据库的国家字符集，可选 "UTF8" or "AL16UTF16"，建议 UTF-8
NATIONALCHARACTERSET= "UTF8"

# 为 Oracle 分配的内存(MB)
TOTALMEMORY = "10240"
```

```
# 字符集（CHARACTERSET）：
    (1) 用来存储 CHAR， VARCHAR2， CLOB， LONG 等类型数据
    (2) 用来标示诸如表名、列名以及 PL/SQL 变量等
    (3) 用来存储 SQL 和 PL/SQL 程序单元等
  命名遵循以下命名规则：<Language><bitsize><encoding>   即: <语言><比特位数><编码>
  AL32UTF8：AL，代表 all，指使用所有语言；32，32 位；UTF8 编码

# 国家字符集（NATIONALCHARACTERSET）：
    (1) 用以存储 NCHAR， NVARCHAR2， NCLOB 等类型数据
    (2) 国家字符集实质上是为 oracle 选择的附加字符集，主要作用是为了增强 oracle 的字符处理能力，因为
    	NCHAR 数据类型可以提供对亚洲使用定长多字节编码的支持，而数据库字符集则不能。国家字符集在 oracle9i 
    	中进行了重新定义，只能在 unicode 编码中的 UTF8 和 AF16UTF16中选择，默认值是 AF16UTF16
```

使⽤ dbca 静默建库：

```shell
cd /home/oracle/database/response
dbca -silent -responseFile /home/oracle/database/response/my_dbca.rsp
```

![image-20200325230157838](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200325230157838.png)

##### 9、配置监听

使⽤ oracle ⽤户执⾏：`su - oracle`

```shell
# 执⾏完成后，会在 $ORACLE_HOME/network/admin ⽬录下⽣成 sqlnet.ora 和 listener.ora 两个⽂件
cd /home/oracle/database/response
netca /silent /responsefile /home/oracle/database/response/netca.rsp
```

注册 sid：`vim $ORACLE_HOME/network/admin/listener.ora`

```shell
# 1、将 LISTENER 中 HOST 修改为主机名
# 2、添加以下内容，(PROGRAM = extproc) 需要注释掉，否则后⾯会导致客户端⽆法连接，连接时报错：ORA-12514，sid_name 与应答文件中一致
SID_LIST_LISTENER = 
 (SID_LIST =    
     (SID_DESC =   
	 (SID_NAME = orcl)    
	 (ORACLE_HOME = /home/oracle/app/oracle/product/11gr2/dbhome_1)
	 #(PROGRAM = extproc)    
	 ) 
 )
```

![image-20200709161036238](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200709161036238.png)

修改后重启监听：`lsnrctl reload`

查看监听状态：`lsnrctl status`

![image-20200709162005159](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200709162005159.png)

使⽤ sqlplus 本机测试：`sqlplus / as sysdba`

```sql
-- 查看实例状态
SQL> select status from v$instance;
```

![image-20200709163238460](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200709162818045.png)

##### 10、配置数据库

```sql
-- 查看 sid 
SQL> show parameter instance_name;
```

![image-20200325233251985](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200325233251985.png)

修改数据库最⼤连接数和密码有效期

```sql
-- 当前的数据库连接数 
SQL> select count(*) from v$process;

-- 查询最大连接数，默认为 150
SQL> show parameter processes;

-- 修改最大连接数
SQL> alter system set processes = 2000 scope = spfile; 

-- 关闭数据库实例
SQL> shutdown immediate; 

-- 启动数据库实例
SQL> startup;

-- 查询密码有效期，默认为 180 天
SQL> SELECT * FROM dba_profiles s WHERE s.profile='DEFAULT' AND resource_name='PASSWORD_LIFE_TIME';

-- 密码有效期修改为无限期，无需重启数据库
SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
```

![image-20200709162818045](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200709163238460.png)

##### 11、设置开机自启

进入 oracle 用户下，修改启动脚本如下：`vim $ORACLE_HOME/bin/dbstart`

![image-20200708185531372](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200708185408774.png)

修改关闭脚本如下：`vim $ORACLE_HOME/bin/dbshut`

![image-20210825162141723](media/image-20210825162141723.png)

修改 oratab 选线，将 N 改成 Y：`vim /etc/oratab`

![image-20200708185408774](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200708185531372.png)

进入 root 用户，修改配置：`vim /etc/rc.d/rc.local`

```shell
# 在末尾加上 oracle 自带的 dbstart 启动脚本
su - oracle -lc "/home/oracle/app/oracle/product/11gr2/dbhome_1/bin/dbstart"
```

![image-20200708185901783](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200708185901783.png)

添加执行权限：`chmod +x /etc/rc.d/rc.local`

#### 二、可能遇到的问题

##### 1、重装 Oracle

当再次执⾏安装命令时，会报错 

> SEVERE: [FATAL] [INS-32025] The chosen installation conflicts with software already installed in the given Oracle home.

 解决⽅法:

删除<HOME_LIST>下的所有内容，然后再试：`vi /home/oracle/inventory/ContentsXML/inventory.xml` 

##### 2、plsql 连接报错

> ORA-12514: TNS:listener does not currently know of service requested in connect descriptor

- 检查 $ORACLE_HOME/network/admin/listener.ora 配置
- 配置监听配置了 SID_LIST_LISTENER 
- 其中的 sid 有没有写错

##### 3、重启监听时报错

> TNS-01201: Listener cannot find executable homeoracleapporaclebinoracle for SID zzwx

- 检查 $ORACLE_HOME 是否与 listener.ora 中的配置⼀致， 这个报错是由于没有找到正确的 $ORACLE_HOME 导致， 修改 listener.ora 中的 ORACLE_HOME 解决

##### 4、检测环境报错

> [FATAL] [INS-13013] Target environment do not meet some mandatory requirements

- 这种报错表示环境检测有的不满⾜， 要看具体情况， 对不是必要的条件不满⾜， 可以选择忽略. 在 安装命令中增加` -ignorePrereq`

```shell
.runInstaller -silent -ignorePrereq -debug -force -responseFile /home/oracle/database/response/my_db_install.rsp
```

![image-20200319003641004](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200319003641004.png)

##### 5、swap 报错

> ./runInstaller -silent -debug -force -responseFile /home/oracle/database/response/my_db_install.rsp
> Starting Oracle Universal Installer...
>
> Checking Temp space: must be greater than 120 MB.   Actual 38285 MB    Passed
> Checking swap space: 0 MB available, 150 MB required.    Failed <<<<
>
> Some requirement checks failed. You must fulfill these requirements before
>
> continuing with the installation, Exiting Oracle Universal Installer,  log for this session can be found at /tmp/OraInstall20190-03-19_12-19-38PM/installActions2019-03-19_12-19-38PM.log

解决方法：

① 检查 Swap 空间在设置 Swap 文件之前，有必要先检查一下系统里有没有既存的 Swap 文件。运行以下命令：

```shell
swapon -s
```

如果返回的信息概要是空的，则表示 Swap 文件不存在

如果有则需要先关闭 swap 分区：`swapoff -a`，修改完成后再开启 swap 分区：`swapon -a`

```shell
swapoff -a
```

![image-20200319004638911](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200319004638911.png)

② 检查文件系统在设置 Swap 文件之前，同样有必要检查一下文件系统，看看是否有足够的硬盘空间来设置 Swap 。运行以下命令：

```shell
df -hal
```

③ 创建并允许 Swap 文件下面使用 dd 命令来创建 Swap 文件。检查返回的信息，还剩余足够的硬盘空间即可。

```shell
dd if=/dev/zero of=/swapfile bs=1024 count=3072k
```

>  参数说明：
>
> if=filename：输入文件名，缺省为标准输入。即指定源文件。
>
> < if=input file > of=filename：输出文件名，缺省为标准输出。即指定目的文件。
>
> < of=output file > bs=bytes：同时设置读入/输出的块大小为 bytes 个字节 count=blocks：仅拷贝 blocks 个块，块大小等于 bs 指定的字节数

④ 格式化并激活 Swap 文件上面已经创建好 Swap 文件，还需要格式化后才能使用。运行命令：

```shell
mkswap /swapfile
```

激活 Swap ，运行命令开启 swap 分区：

```shell
swapon /swapfile
```

![image-20200319005042871](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200319005119708.png)

以上步骤做完，再次运行命令：

```shell
swapon -s
```

  你会发现返回的信息概要：

![image-20200319005119708](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20200319005042871.png)

 如果要机器重启的时候自动挂载 Swap ，那么还需要修改 fstab 配置，在其最后添加如下一行：`vi /etc/fstab`

```shell
/swapfile          swap            swap    defaults        0 0
```

最后，赋予 Swap 文件适当的权限：

```shell
chown root:root /swapfile 
chmod 0600 /swapfile
```

##### 6、plsql 查询数据乱码

![image-20210203161342912](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20210203161342912.png)

```sql
-- 查询 oracle server 端的字符集
SQL> select userenv('language') from dual;

USERENV('LANGUAGE')
----------------------------------------------------
AMERICAN_AMERICA.AL32UTF8
```

添加 NLS_LANG 为系统环境变量，与查询结果保持一致，重启plsql

![image-20210203161649530](https://cdn.jsdelivr.net/gh/FlyNine/cloudimage/oracle/image-20210203161649530.png)

##### 7、修改字符集

导入 dmp 文件时需要 oracle server 端、client 端和 dmp 文件的字符集都一致才能正确导入

ZHS16GBK 修改字符集为 AL32UTF8：`sqlplus / as sysdba`

```sql
SQL> shutdown immediate;
SQL> STARTUP MOUNT;
SQL> ALTER SESSION SET SQL_TRACE=TRUE;
SQL> ALTER SYSTEM ENABLE RESTRICTED SESSION;
SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES=0;
SQL> ALTER SYSTEM SET AQ_TM_PROCESSES=0;
SQL> ALTER DATABASE OPEN;
SQL> ALTER DATABASE character set INTERNAL_USE AL32UTF8;
SQL> ALTER SESSION SET SQL_TRACE=FALSE;
SQL> shutdown immediate;
SQL> startup;
```

```sql
SQL> select userenv('language') from dual;
 
USERENV('LANGUAGE')
----------------------------------------------------
AMERICAN_AMERICA.AL32UTF8
 
-- 查看变更记录
SQL> SELECT parameter, value FROM v$nls_parameters WHERE parameter LIKE '%CHARACTERSET';
 
PARAMETER
----------------------------------------------------------------
VALUE
----------------------------------------------------------------
NLS_CHARACTERSET
AL32UTF8
 
NLS_NCHAR_CHARACTERSET
UTF8
```

字符集相关资料：

- [Oracle 字符集的查看和修改](https://www.cnblogs.com/rootq/articles/2049324.html )

- [ORACLE HANDBOOK 系列之十：字符集、编码以及 Oracle 的那些事](https://www.cnblogs.com/morvenhuang/archive/2011/11/11/2245410.html )

