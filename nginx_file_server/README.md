# 基于docker的网络目录浏览器

基于nginx的静态文件服务器，列出目录

默认内部挂载点为 `/workpath`

## 运行方法

```bash
docker run -ti --rm -v path-to-dir:/workpath -p 80:80 zctmdc/file-server
```

### iso文件将自动挂载

```bash
docker run -ti --rm -v path-to-iso:/workpath -p 80:80 zctmdc/file-server
```

其他类型文件将会出错！！！
