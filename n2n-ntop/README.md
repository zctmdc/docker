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
  -e MODE="SUPERNODE" \
  -e SUPERNODE_PORT=10086 \
  -p 10086:10086/udp \
  zctmdc/n2n_ntop
```

在powershell中换行符号为 **`**    键盘TAB按钮上方

在CMD中换行符号为 **＾**    键盘SHIFT+6

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
  -e MODE="DHCP" \
  -e 2N_INTERFACE=edge0
  -e STATIC_IP="10.0.0.10" \
  -e N2N_GROUP="zctmdc_dhcp" \
  -e N2N_PASS="zctmdc_dhcp" \
  -e N2N_SERVER="n2n.lucktu.com:10086" \
  zctmdc/n2n_ntop
```

## 更多模式

请访问:github地址
docker-compose up -d

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
