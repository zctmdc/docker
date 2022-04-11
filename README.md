# 我的 DOCKER CODE:Beta

你好，这是我个人 docker 文件

## 目录基本介绍

|目录|基本介绍|
|---:|:---|
|n2n_ntop|是一个 **第二层对等 VPN**，可轻松创建绕过中间防火墙的虚拟网络。|
|n2n_proxy|只需要 **开放一个端口** ,就可以在软件上使用代理,连接远程设备|

点进去查看单项介绍,有详细使用说明

## 使用方法

|基本介绍|命令|
|---:|:---|
|编译镜像|`docker-compose build` |
|全部运行|`docker-compose up -d` |
|单个运行|`docker-compose up ${name}`   |

更多介绍请访问 [docker-compose CLI概述][Overview of docker-compose CLI]

## 还可以使用 *docker-compose* 配置运行

### 例如运行n2n_proxy_dhcp

```bash
git clone -b alpha https://github.com/zctmdc/docker.git
cd n2n_proxy
docker-compose build
vim docker-compose.yaml
# docker-compose up -d
# docker-compose up n2n_proxy_dhcp
```

## 告诉我你在用

如果你使用正常了请点个赞
[我的docker主页][zctmdc—docker] 和 [我github的docker项目页][zctmdc—github]

我将引起注意，不再随意的去更改和重命名空间/变量名

[zctmdc—docker]: https://hub.docker.com/u/zctmdc "我的docker主页"
[zctmdc—github]: https://github.com/zctmdc/docker.git "我github的docker项目页"
[Overview of docker-compose CLI]: https://docs.docker.com/compose/reference/overview/ "docker-compose CLI概述"
