# 基于docker的网络目录浏览器

基于nginx的静态文件服务器，列出目录

默认内部挂载点为 `/workpath`

## 运行方法

### docker

```bash
docker run -ti --rm \
 -v path-to-dir:/workpath \
 -p 80:80 \
 zctmdc/file-server:Alpha
```

### docker-compose

```bash
git clone -b alpha https://github.com/zctmdc/docker.git
cd nginx_file_server
# vim docker-compose.yaml #自定义配置
# docker-compose up --build file-server_dir #前台编译并运行 n2n_edge_dhcp
# docker-compose up -d --build file-server_dir #后台运行
```


### iso文件将自动挂载

```bash
docker run \
 -ti --rm \
 -v path-to-iso:/workpath \
 -p 8088:80 \
 zctmdc/file-server:Alpha
```

> 挂载文件的方式为 `mount -o loop $file` ，其他类型文件可能会出错！

然后使用浏览器访问 [http://localhost:8088](http://localhost:8088?_blank) 进行测试
