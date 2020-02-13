# 基于docker的网络目录浏览器

基于nginx的静态文件服务器，列出目录

默认内部挂载点为 `/workpath`

## 运行方法

### docker

```bash
docker run -ti --rm \
 -v path-to-dir:/workpath \
 -p 80:80 \
 zctmdc/file-server:alpha
```

### docker-compose

```bash
git clone -b alpha https://github.com/zctmdc/docker.git
cd nginx_file_server
# docker-compose up -d
docker-compose build
docker-compose run file-server_dir
```

### iso文件将自动挂载

```bash
docker run \
 -ti --rm \
 -v path-to-iso:/workpath \
 -p 8088:80 \
 zctmdc/file-server:alpha
```

> 挂在方式为 `mount -o loop` ，其他类型文件可能会出错！

然后使用浏览器访问 [http://localhost:8088](http://localhost:8088?_blank) 进行测试
