# docker n2n_ntop:Beta

## 关于

[n2n][n2n] 是一个 **第二层对等 VPN**，可轻松创建绕过中间防火墙的虚拟网络。

通过编译 [ntop 团队][ntop] 发布的n2n,直连成功率高(仅局域网内不及), 且速度更快.

N2N 是通过UDP方式建立链接，如果某个网络禁用了 UDP，那么该网络下的设备就不适合使用本软件来加入这个虚拟局域网（用"blue's port scanner"，选择UDP来扫描，扫出来的就是未被封的，正常情况下应该超级多）

为了开始使用N2N，需要两个元素：

1. *supernode* ：
它允许edge节点链接和发现其他edge的超级节点。
它必须具有可在公网上公开端口。

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

通过以下符号分行,你可以分行输入你需要运行的代码

|终端|符号|按键方法|
---:|:---:|:---|
|bash| \\ | 回车键上方 |
|powershell|**`**|键盘TAB按钮上方|
|CMD|**＾**|键盘SHIFT+6|

### 快速测试

```bash
docker run --rm -ti \
 -p 10086:10086 zctmdc/n2n_ntop:Beta \
 supernode -l 10086 -v
```

### 建立 *supernode*

* 前台模式

```bash
docker run \
  --rm -ti \
  -e MODE="SUPERNODE" \
  -p 10086:10086/udp \
  zctmdc/n2n_ntop:Beta
```

* 后台模式

```bash
docker run \
  -d --restart=always \
  --name=supernode \
  -e MODE="SUPERNODE" \
  -e SUPERNODE_PORT=10086 \
  -p 10086:10086/udp \
  zctmdc/n2n_ntop:Beta
```

### 建立 *edge*

* 前台模式

```bash
docker run --rm -ti --privileged zctmdc/n2n_ntop:Beta
```

* 后台模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge \
  --privileged \
  --net=host \
  -e MODE="STATIC" \
  -e EDGE_IP="10.10.10.10" \
  -e EDGE_COMMUNITY="n2n" \
  -e EDGE_KEY="test" \
  -e SUPERNODE_HOST=n2n.lucktu.com \
  -e SUPERNODE_PORT=10086 \
  -e EDGE_ENCRYPTION=A3 \
  -e N2N_ARGS="-f" \
  zctmdc/n2n_ntop:Beta
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
  zctmdc/n2n_ntop:Beta
```

### DHCPD - DHCP服务端模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge \
  --privileged \
  --net=host \
  -e MODE="DHCPD" \
  -e EDGE_IP="10.10.10.1" \
  -e EDGE_COMMUNITY="n2n" \
  -e EDGE_KEY="test" \
  -e SUPERNODE_HOST=n2n.lucktu.com \
  -e SUPERNODE_PORT=10086 \
  -e EDGE_ENCRYPTION=A3 \
  -e N2N_ARGS="-f" \
  zctmdc/n2n_ntop:Beta
```


如果你需要自定义DHCPD服务配置文件

 ```bash
 -v path/to/dhcpd.conf:/etc/dhcp/dhcpd.conf:ro \
 ```

### DHCP - DHCP动态IP模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge \
  --privileged \
  --net=host \
  -e MODE="DHCP" \
  -e EDGE_COMMUNITY="n2n" \
  -e EDGE_KEY="test" \
  -e SUPERNODE_HOST=n2n.lucktu.com \
  -e SUPERNODE_PORT=10086 \
  -e EDGE_ENCRYPTION=A3 \
  -e N2N_ARGS="-f" \
  zctmdc/n2n_ntop:Beta
```


### STATIC - 静态IP模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge \
  --privileged \
  --net=host \
  -e MODE="STATIC" \
  -e EDGE_IP="10.10.10.10" \
  -e EDGE_COMMUNITY="n2n" \
  -e EDGE_KEY="test" \
  -e SUPERNODE_HOST=n2n.lucktu.com \
  -e SUPERNODE_PORT=10086 \
  -e EDGE_ENCRYPTION=A3 \
  -e N2N_ARGS="-f" \
  zctmdc/n2n_ntop:Beta
```


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
|EDGE_TUN|网卡名|edge使用的网卡名|-d $EDGE_TUN|
|N2N_ARGS|更多参数|运行时附加的更多参数|-v -f|

更多帮助请参考 [好运博客][好运博客] 中 [N2N 新手向导及最新信息][N2N 新手向导及最新信息]

更多节点请访问 [N2N中心节点][N2N中心节点]

## 使用 *docker-compose* 配置运行

```bash
git clone -b Beta https://github.com/zctmdc/docker.git
# docker-compose build #编译

#启动 n2n_edge_dhcp
cd n2n_ntop
# docker-compose up n2n_edge_dhcp #前台运行 n2n_edge_dhcp
# docker-compose up -d n2n_edge_dhcp #后台运行
```

更多介绍请访问 [docker-compose CLI概述][Overview of docker-compose CLI]

## 告诉我你在用

如果你使用正常了请点个赞
[我的docker主页][zctmdc—docker] ，[n2n_ntop的docker项目页][n2n_ntop] 和 [我github的docker项目页][zctmdc—github]
我将引起注意，不再随意的去更改和重命名空间/变量名

[n2n]: https://web.archive.org/web/20110924083045/http://www.ntop.org:80/products/n2n/ "n2n官网"
[ntop]: https://github.com/ntop "ntop团队"
[组网示意]: https://web.archive.org/web/20110924083045im_/http://www.ntop.org/wp-content/uploads/2011/08/n2n_network.png "组网示意"
[连接原理]: https://web.archive.org/web/20110924083045im_/http://www.ntop.org/wp-content/uploads/2011/08/n2n_com.png "连接原理"
[好运博客]: http://www.lucktu.com "好运博客"
[N2N 新手向导及最新信息]: http://www.lucktu.com/archives/783.html "N2N 新手向导及最新信息（2019-12-05 更新）"
[N2N中心节点]: http://supernode.ml/ "N2N中心节点"

[zctmdc—docker]: https://hub.docker.com/u/zctmdc "我的docker主页"
[zctmdc—github]: https://github.com/zctmdc/docker.git "我github的docker项目页"
[n2n_ntop]: https://hub.docker.com/r/zctmdc/n2n_ntop "n2n_ntop的docker项目页"
[n2n_proxy]: https://hub.docker.com/r/zctmdc/n2n_proxy "n2n_proxy的docker项目页"
[Overview of docker-compose CLI]: https://docs.docker.com/compose/reference/overview/ "docker-compose CLI概述"
