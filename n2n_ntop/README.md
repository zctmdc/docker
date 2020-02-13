# docker n2n

## 关于

[n2n][n2n] 是一个 **第二层对等 VPN**，可轻松创建绕过中间防火墙的虚拟网络。

通过 [ntop 团队][ntop] 编译的n2n,直连成功率高(仅局域网内不及), 且速度更快.

N2N 是通过UDP方式建立链接，如果某个网络禁用了 UDP，那么该网络下的设备就不适合使用本软件来加入这个虚拟局域网（用"blue's port scanner"，选择UDP来扫描，扫出来的就是未被封的，正常情况下应该超级多）

为了开始使用N2N，需要两个元素：

1. *supernode* ：
它允许edge节点链接和发现其他edge的超级节点。
它必须具有可在公网上公开访问的端口。

2. *edge* ：将成为虚拟网络一部分的节点;
在n2n中的多个边缘节点之间共享的虚拟网络称为community。

单个supernode节点可以中继多个edge，而单个电脑可以同时连接多个supernode。
边缘节点可以使用加密密钥对社区中的数据包进行加密。
n2n尽可能在edge节点之间建立直接的P2P连接;如果不可能（通常是由于特殊的NAT设备），则超级节点也用于中继数据包。

### 组网示意

![组网示意][组网示意]

### 连接原理

![连接原理][连接原理]

## 快速入门

### 代码换行

|终端|符号|按键方法|
---:|:---:|:---|
|bash| \\ | 回车键上方 |
|powershell|**`**|键盘TAB按钮上方|
|CMD|**＾**|键盘SHIFT+6|

### 自写运行代码

```bash
docker run --rm -ti -p 10086:10086 zctmdc/n2n_ntop supernode -l 10086 -v
```

### 建立 *supernode*

* 前台模式

```bash
docker run \
  --rm -ti \
  -e MODE="SUPERNODE" \
  -p 10086:10086/udp \
  zctmdc/n2n_ntop
```

* 后台模式

```bash
docker run \
  -d --restart=always \
  --name=supernode \
  -e MODE="SUPERNODE" \
  -e SUPERNODE_PORT=10086 \
  -p 10086:10086/udp \
  -e N2N_ARGS="-v"
  zctmdc/n2n_ntop
```

### 建立 *edge*

* 前台模式

```bash
docker run \
  --rm -ti \
  --privileged \
  zctmdc/n2n_ntop
```

* 后台模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge \
  --privileged \
  --net=host \
  -e MODE="STATIC" \
  -e STATIC_IP="10.0.10.10" \
  -e N2N_GROUP="zctmdc_proxy" \
  -e N2N_PASS="zctmdc_proxy" \
  -e N2N_SERVER="n2n.lucktu.com:10086" \
  -e N2N_ARGS="-Av" \
  zctmdc/n2n_ntop
```

## 更多模式

### SUPERNODE - 超级节点

```bash
docker run \
  -d --restart=always \
  --name=supernode \
  -e MODE="SUPERNODE" \
  -e SUPERNODE_PORT=10086 \
  -p 10086:10086/udp \
  zctmdc/n2n_ntop
```

### DHCPD - DHCP服务模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge_dhcpd \
  --privileged \
  -e MODE="DHCPD" \
  --net=host \
  -e STATIC_IP="10.0.10.1" \
  -v path/to/dhcpd.conf:/etc/dhcp/dhcpd.conf:ro \
  -e N2N_GROUP="zctmdc_proxy" \
  -e N2N_PASS="zctmdc_proxy" \
  -e N2N_SERVER="n2n.lucktu.com:10086" \
  zctmdc/n2n_ntop
```

指定STATIC_IP和-v dhcpd.conf:/etc/dhcp/dhcpd.conf:ro 文件

### DHCP - DHCP客户端模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge_dhcp \
  --privileged \
  --net=host \
  -e MODE="DHCP" \
  -e N2N_GROUP="zctmdc_proxy" \
  -e N2N_PASS="zctmdc_proxy" \
  -e N2N_SERVER="n2n.lucktu.com:10086" \
  zctmdc/n2n_ntop
```

### STATIC - 静态模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge_static \
  --privileged \
  --net=host \
  -e MODE="STATIC" \
  -e STATIC_IP="10.0.10.10" \
  -e N2N_GROUP="zctmdc_proxy" \
  -e N2N_PASS="zctmdc_proxy" \
  -e N2N_SERVER="n2n.lucktu.com:10086" \
  zctmdc/n2n_ntop
```

## 环境变量介绍

|变量名|变量说明|备注|对应参数|
|---:|:---|:---|:---|
|MODE|模式|对应启动的模式| *`SUPERNODE`* *`DHCP`* *`STATIC`* *`DHCPD`* |
|SUPERNODE_PORT|超级节点端口|在SUPERNODE中使用|-l|
|N2N_SERVER|要连接的N2N超级节点|IP:port|-l|
|STATIC_IP|静态IP|在静态模式和DHCPD使用|-a|
|N2N_GROUP|组网名称|在EDGE中使用|-c|
|N2N_PASS|组网密码|在EDGE中使用|-k|
|N2N_INTERFACE|网卡名|edge生成的网卡名字|-d|
|N2N_ARGS|更多参数|运行时附加的更多参数|-Av|

## 还可以使用 *docker-compose* 配置运行

```bash
git clone https://github.com/zctmdc/docker.git
cd n2n-ntop
# docker-compose up -d
docker-compose run n2n_edge_dhcp
```

请访问:[github地址][github地址]查看更多

### 更多帮助请参考

[好运博客][好运博客]中[N2N 新手向导及最新信息][N2N 新手向导及最新信息]

更多节点请访问 [N2N中心节点][N2N中心节点]

[n2n]: https://web.archive.org/web/20110924083045/http://www.ntop.org:80/products/n2n/ "n2n官网"
[ntop]: https://github.com/ntop "ntop团队"
[组网示意]: https://web.archive.org/web/20110924083045im_/http://www.ntop.org/wp-content/uploads/2011/08/n2n_network.png "组网示意"
[连接原理]: https://web.archive.org/web/20110924083045im_/http://www.ntop.org/wp-content/uploads/2011/08/n2n_com.png "连接原理"
[好运博客]: http://www.lucktu.com "好运博客"
[N2N 新手向导及最新信息]: http://www.lucktu.com/archives/783.html "N2N 新手向导及最新信息（2019-12-05 更新）"
[N2N中心节点]: http://supernode.ml/ "N2N中心节点"
[github地址]: https://github.com/zctmdc/docker/n2n-ntop "github地址"
