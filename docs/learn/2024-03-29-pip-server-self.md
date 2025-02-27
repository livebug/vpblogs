---
title : '自建 pip 私有源'
date : 2024-02-25T17:30:25+08:00
toc: true
tags: ['python','pypi']

---
# 自建 pip 私有源

1. pypiserver 下载包

https://files.pythonhosted.org/packages/34/95/6c70e2f7e8375354fd7b1db08405c93674f2e4ce4e714f379fadd06a92b1/pypiserver-2.0.1-py2.py3-none-any.whl

2. 服务器安装
```bash
pip install pypiserver-2.0.1-py2.py3-none-any.whl 
```

3. 准备一个存放位置  `～/pypiserver/packages/`

4. 手工启动
```bash
pypi-server run -p 9000 ./packages/
```
访问  http://127.0.0.1:9000/ 即可

pip安装时引用：
```bash
pip install --index-url http://127.0.0.1:9000/simple/ 
```

5. 服务配置（可选）

```yml
# /etc/systemd/system/pypi_server.service
[Unit]
Description=A minimal PyPI server for use with pip/easy_install.
After=network.target

[Service]
Type=simple
# systemd requires absolute path here too.
PIDFile=/var/run/pypiserver.pid
User=www-data
Group=www-data
# 启动命令&日志文件存放位置
ExecStart=/usr/local/bin/pypi-server -p 9090 -a update,download --log-file /var/log/pypiserver.log /root/home/packges
ExecStop=/bin/kill -TERM $MAINPID
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
# 模块存放地址
WorkingDirectory=/root/home/packages

TimeoutStartSec=3
RestartSec=5

[Install]
WantedBy=multi-user.target
```
启动脚本
```bash
systemctl enable pypi_server

# 后期维护
$ systemctl status pypi_server    # 查看进程状态
$ systemctl stop pypi_server    # 终止 pypi_server 进程
$ systemctl start pypi_server    # 启动 pypi_server 进程
$ systemctl restart pypi_server    # 重新启动 pypi_server 进程
```

6. 下载包 注意版本的话需要自己另外下载
```bash
pip list --format=freeze > re.txt
# cat re.txt 
pip download -r ./re.txt -d .
```

