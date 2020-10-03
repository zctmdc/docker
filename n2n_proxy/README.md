# N2N proxy:Alpha

基于[zctmdc/n2n_ntop][n2n_ntop]和[pginuerzh/gost][gost]制作的P2P远程代理

只需要开放一个端口,就可以在软件上使用代理,连接远程设备

## 使用方法

### 测试

```shell
docker run -ti --rm zctmdc/n2n_proxy:Alpha
```

### 远端/网络共享端

```shell
docker run \
  -d --restart=always \
  --name n2n_proxy_nat \
  --privileged \
  -e MODE="DHCPD" \
  -e EDGE_IP="10.10.10.1" \
  -e EDGE_COMMUNITY="n2n" \
  -e EDGE_KEY="test" \
  -e SUPERNODE_HOST=n2n.lucktu.com \
  -e SUPERNODE_PORT=10086 \
  -e EDGE_ENCRYPTION=A3 \
  -e N2N_ARGS="-f" \
  # -v path/to/dhcpd.conf:/etc/dhcp/dhcpd.conf:ro \
  -e EDGE_NAT=TRUE \
  -e EDGE_PROXY=FALSE \
  zctmdc/n2n_proxy:Alpha
```

### 近端/代理路口端

```shell
docker run \
  -d --restart=always \
  --name n2n_proxy_gw \
  --privileged \
  -e MODE="DHCP" \
  -e EDGE_COMMUNITY="n2n" \
  -e EDGE_KEY="test" \
  -e SUPERNODE_HOST=n2n.lucktu.com \
  -e SUPERNODE_PORT=10086 \
  -e EDGE_ENCRYPTION=A3 \
  -e N2N_ARGS="-f" \
  -e EDGE_GATEWAY="10.10.10.1"\
  -e EDGE_PROXY=TRUE \
  -e PROXY_ARGS="-L=:14080" \
  -p 14080:14080 \
  zctmdc/n2n_proxy:Alpha
```

然后你就可以使用14080端口进行代理,访问远程资料

### 手动添加路由表

```shell
docker exec -t n2n_proxy_gw \
  route add [-net|-host] $EDGE_DESTINATION gw $EDGE_GATEWAY

```

> 请修改 *$EDGE_DESTINATION* 和 *$EDGE_GATEWAY*

```shell
#  比如增加192.168.77.1-255网域的下一跳为10.0.10.77
docker exec -t n2n_proxy_gw \
  route add -net 192.168.77.0/24 gw 10.0.10.77


# 或者增加192.168.78.5地址的下一跳为10.0.10.78
docker exec -t n2n_proxy_gw \
  route add -host 192.168.78.5 gw 10.0.10.78
```

#### route - 更多介绍

```shell
route [add|del] [-net|-host] [网域或主机] netmask [mask] [gw|dev]
观察的参数：
   -n      ：不要使用通讯协定或主机名称，直接使用 IP 或 port number；
   -ee     ：使用更详细的资讯来显示

增加 (add) 与删除 (del) 路由的相关参数：
   -net    ：表示后面接的路由为一个网域；
   -host   ：表示后面接的为连接到单部主机的路由；
   netmask ：与网域有关，可以设定 netmask 决定网域的大小；
   gw      ：gateway 的简写，后续接的是 IP 的数值喔，与 dev 不同；
   dev     ：如果只是要指定由那一块网路卡连线出去，则使用这个设定，后面接 eth0 等
```

更多请看: [linux route命令的使用详解][route]

## 环境变量介绍


|变量名|变量说明|备注|对应参数|
|---:|:---|:---|:---|
|MODE|模式|对应启动的模式| *`SUPERNODE`* *`DHCPD`*  *`DHCP`* *`STATIC`* |
|SUPERNODE_PORT|超级节点端口|在SUPERNODE/EDGE中使用|-l $SUPERNODE_PORT|
|SUPERNODE_HOST|要连接的N2N超级节点|IP/HOST|-l $SUPERNODE_HOST:$SUPERNODE_PORT|
|EDGE_IP|静态IP|在静态模式和DHCPD使用|-a $EDGE_IP|
|EDGE_COMMUNITY|组网名称|在EDGE中使用|-c $EDGE_COMMUNITY|
|EDGE_KEY|组网密码|在EDGE中使用|-k $EDGE_KEY|
|EDGE_ENCRYPTION|加密方式|edge间连接加密方式|-A2 = Twofish (default), -A3 or -A (deprecated) = AES-CBC, -A4 = ChaCha20, -A5 = Speck-CTR.|
|EDGE_TUN|网卡名|edge生成的网卡名字|-d $EDGE_TUN|
|N2N_ARGS|更多参数|运行时附加的更多参数|-v -f|
|---|---|---|---|
|EDGE_DESTINATION|目标网络|想要访问的远程地址| `192.168.0.0/16` `192.168.1.10`|
|EDGE_GATEWAY|网关地址|远程共享docker的网卡地址,用于网络出口|10.10.10.1|
|EDGE_ROUTE|是否添加路由|将访问目标网络路由表添加到近端docker|FALSE|
|EDGE_NAT|是否开启NAT转发|允许其他docker访问本机网络内容|FALSE|
|EDGE_PROXY|是否开启代理|是否开启HTTP/SOCKS5代理|TRUE|
|PROXY_ARGS|代理参数|具体参数访问 *[pginuerzh/gost][gost]* 查看|-L=:14080|

更多介绍参看 *[zctmdc/n2n_ntop][n2n_ntop]* 和 *[pginuerzh/gost][gost]*

## 还可以使用 *docker-compose* 配置运行

```shell
git clone -b alpha https://github.com/zctmdc/docker.git
docker-compose build
cd n2n_proxy
vim docker-compose.yaml
docker-compose up -d
# docker-compose up n2n_proxy_dhcp
```

更多介绍请访问 [docker-compose CLI概述][Overview of docker-compose CLI]

## 告诉我你在用

如果你使用正常了请点个赞
[我的docker主页][zctmdc—docker] ，[n2n_proxy的docker项目页][n2n_proxy] 和 [我github的docker项目页][zctmdc—github]

我将引起注意，不再随意的去更改和重命名空间/变量名

[gost]:https://github.com/ginuerzh/gost "ginuerzh/gost的GITHUB地址"
[route]:https://www.cnblogs.com/snake-hand/p/3143041.html "linux route命令的使用详解"
[zctmdc—docker]: https://hub.docker.com/u/zctmdc "我的docker主页"
[zctmdc—github]: https://github.com/zctmdc/docker.git "我github的docker项目页"
[n2n_ntop]: https://hub.docker.com/r/zctmdc/n2n_ntop "n2n_ntop的docker项目页"
[n2n_proxy]: https://hub.docker.com/r/zctmdc/n2n_proxy "n2n_proxy的docker项目页"
[Overview of docker-compose CLI]: https://docs.docker.com/compose/reference/overview/ "docker-compose CLI概述"
