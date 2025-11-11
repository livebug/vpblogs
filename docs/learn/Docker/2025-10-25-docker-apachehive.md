---
title: docker 启动hive
tags:
  - docker
  - hive
---
# docker 启动hive

## 命令： 
启动带有内嵌元数据存储的 HiveServer2，
```bash
docker run -d -p 10000:10000 -p 10002:10002 --env SERVICE_NAME=hiveserver2 --name hiveserver2-standalone apache/hive:4.0.0
```

[Apache Hive : 使用 Docker 设置 Hive --- Apache Hive : Setting Up Hive with Docker](https://hive.apache.org/docs/latest/admin/setting-up-hive-with-docker/)


## 连接测试

### HiveServer2 

在浏览器中访问 `http://localhost:10002/`
![](../../public/images/Pasted%20image%2020251025151429.png)

###  Beeline:
```bash
docker exec -it hiveserver2-standalone beeline -u 'jdbc:hive2://127.0.0.1:10000/'  
```

![](../../public/images/Pasted%20image%2020251025151459.png)