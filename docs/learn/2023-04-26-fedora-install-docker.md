---
title: fedora安装docker
date: 2023-04-26 23:38:56
toc: true
tags:
- docker
- gauss
- fedora
- linux

---
# fedora安装docker

*[安装参考教程连接](https://help.aliyun.com/document_detail/264695.html?spm=5176.21213303.J_6028563670.38.3acf3eda1H4cBI&scm=20140722.S_help%40%40%E6%96%87%E6%A1%A3%40%40264695.S_hot.ID_264695-RL_docker%E5%AE%89%E8%A3%85-OR_s%2Bhelpmain-V_1-P0_7)*  

### 简单记录
1. 安装dnf源中默认的Docker（podman-docker）
```bash
# 运行以下命令，安装podman-docker。
dnf -y install docker
# 运行以下命令，查看Docker是否安装成功。
docker images
 
```

### 权限问题
```bash
sudo gpasswd -a $USER docker 
newgrp docker 
docker ps -a

# 调整权限
# permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock:
$ sudo chmod a+rw /var/run/docker.sock
$ sudo service docker restart
```


### 安装gaussdb
```bash
docker run --name opengauss --privileged=true -d -e GS_PASSWORD=Enmo@123 \
    -v /data/opengauss:/var/lib/opengauss  -u root -p 15432:5432 \
    enmotech/opengauss:latest
```

默认用户 gaussdb

#### gauss 使用
```sql
drop table sdopdb.bqqyxx;
create table sdopdb.bqqyxx 
(
	p_year varchar(4) not null,
	p_type varchar(40) NOT NULL,
	p_rank varchar(4) NOT NULL,
	p_busi_nm varchar(100) NOT NULL,
	p_income DECIMAL(20,6) NOT NULL 
);
COMMENT ON TABLE sdopdb.bqqyxx IS '百强企业信息';

select  * from sdopdb.bqqyxx b ;
select * from pg_catalog.pg_collation ;

select  pg_get_tabledef('sdopdb.bqqyxx') ;
-- 查询sql运行 只能查看上层sql执行情况 其实是连接状态的统计
-- 详细的运行计划，还得看 explain 的结果分析
SELECT * FROM pg_stat_activity ;

```


### opengauss 配置 odbc 
fedora 直接安装  
```bash
sudo dnf install unixODBC
```

https://docs.opengauss.org/zh/docs/5.0.0/docs/DeveloperGuide/Linux%E4%B8%8B%E9%85%8D%E7%BD%AE%E6%95%B0%E6%8D%AE%E6%BA%90.html

* 注意点：  

	将openGauss-x.x.x-ODBC.tar.gz解压后lib目录中的库拷贝到“/usr/local/lib”目录下。

	`/usr/local/etc/odbcinst.ini` 和 `/usr/local/etc/odbc.ini` 需要自己建立

	环境变量配好
	```bash
	export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
	export ODBCSYSINI=/usr/local/etc
	export ODBCINI=/usr/local/etc/odbc.ini
	```

	`isql -v MPPODBC`  测试连接