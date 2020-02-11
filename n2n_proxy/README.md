# N2N proxy

基于[zctmdc/n2n_ntop][n2n_ntop]和[pginuerzh/gost][gost]制作的P2P远程代理

只需要开放一个端口,就可以在软件上使用代理,链接远程电脑

## 使用方法

### 测试

```bash
docker run -ti --rm zctmdc/n2n_proxy
```

### 远端/网络共享端

```bash
docker run \
  -d --restart=always \
  --name n2n_proxy_nat \
  --privileged \
  -e MODE="DHCPD" \
  -e STATIC_IP="10.0.10.1" \
  -v path/to/dhcpd.conf:/etc/dhcp/dhcpd.conf:ro
  -e N2N_GROUP="zctmdc_proxy" \
  -e N2N_PASS="zctmdc_proxy" \
  -e N2N_SERVER="n2n.lucktu.com:10086" \
  -e N2N_NAT=TRUE \
  -e N2N_PROXY=FALSE \
  zctmdc/n2n_proxy
```

### 近端/代理路口端

```bash
docker run \
  -d --restart=always \
  --name n2n_proxy_nat \
  --privileged \
  -e MODE="DHCP" \
  -e N2N_GROUP="zctmdc_proxy" \
  -e N2N_PASS="zctmdc_proxy" \
  -e N2N_SERVER="n2n.lucktu.com:10086" \
  -e N2N_GW="TURE" \
  -e N2N_DESTINATION="192.168.0.0/16" \
  -e N2N_GATEWAY="10.0.10.1"\
  -e N2N_PROXY=TRUE \
  -p 1080:1080 \
  zctmdc/n2n_proxy
```

然后你就可以使用1080端口进行代理,访问远程资料

## 环境变量介绍

|变量名|变量说明|备注|对应参数|
|---:|:---|:---|:---|
|MODE|模式|可选 *`SUPERNODE`* *`DHCP`* *`STATIC`* *`DHCPD`* ||
|SUPERNODE_PORT|超级节点端口|在SUPERNODE中使用|-l|
|N2N_SERVER|要连接的N2N超级节点|IP:port|-l|
|STATIC_IP|静态IP|在静态模式和DHCPD使用|-a|
|N2N_GROUP|组网名称|在EDGE中使用|-c|
|N2N_PASS|组网密码|在EDGE中使用|-k|
|N2N_INTERFACE|网卡名|edge生成的网卡名字|-d|
|N2N_ARGS|更多参数|运行时附加的更多参数|-Av|
|N2N_DESTINATION|目标网络|想要访问的远程地址| `192.168.0.0/16` `192.168.1.10`|
|N2N_GATEWAY|网关地址|远程共享docker的网卡地址,用于网络出口|10.0.10.1|
|N2N_GW|是否添加路由|将访问目标网络路由表添加到近端docker|FALSE|
|N2N_NAT|是否开启NAT转发|允许其他docker访问本机网络内容|FALSE|
|N2N_PROXY|是否开启代理|是否开启HTTP/SOCKS5代理|TRUE|
|PROXY_ARGS|代理参数|具体参数访问[pginuerzh/gost][gost]查看|-L=:1080|

更多详情参看:[zctmdc/n2n_ntop][n2n_ntop]和[pginuerzh/gost][gost]

[n2n_ntop]:https://hub.docker.com/r/zctmdc/n2n_ntop "n2n-ntop的docker hub地址"

[gost]:https://github.com/ginuerzh/gost "ginuerzh/gost的GITHUB地址"
