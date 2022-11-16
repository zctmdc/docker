# docker n2n_ntop

## 关于

[n2n][n2n] 是一个 **第二层对等 VPN**，可轻松创建绕过中间防火墙的虚拟网络。

通过编译 [ntop 团队][ntop] 发布的 n2n,直连成功率高(仅局域网内不及), 且速度更快.

N2N 是通过 UDP 方式建立链接，如果某个网络禁用了 UDP，那么该网络下的设备就不适合使用本软件来加入这个虚拟局域网（用"blue's port scanner"，选择 UDP 来扫描，扫出来的就是未被封的，正常情况下应该超级多）

为了开始使用 N2N，需要两个元素：

1. _supernode_ ：
   它允许 edge 节点链接和发现其他 edge 的超级节点。
   它必须具有可在公网上公开端口。

2. _edge_ ：将成为虚拟网络一部分的节点;
   在 n2n 中的多个边缘节点之间共享的虚拟网络称为 community。

单个 supernode 节点可以中继多个 edge，而单个电脑可以同时连接多个 supernode。
边缘节点可以使用加密密钥对社区中的数据包进行加密。
n2n 尽可能在 edge 节点之间建立直接的 P2P 连接;如果不可能（通常是由于特殊的 NAT 设备），则超级节点也用于中继数据包。

### 组网示意

![组网示意][组网示意]

### 连接原理

![连接原理][连接原理]

## 快速入门

### 代码换行

通过以下符号分行,你可以分行输入你需要运行的代码

|       终端 |  符号  | 按键方法          |
| ---------: | :----: | :---------------- |
|       bash |   \\   | 回车键上方        |
| powershell | **`**  | 键盘 TAB 按钮上方 |
|        CMD | **＾** | 键盘 SHIFT+6      |

### 快速测试

```bash
docker run --rm -ti \
 -p 10090:10090  \
 zctmdc/n2n_ntop \
 supernode -p 10090 -vf
```

```bash
docker run --rm -ti \
  -e MODE="DHCPC" \
  zctmdc/n2n_ntop
```

### 建立 _supernode_

- 前台模式

```bash
docker run \
  --rm -ti \
  -e MODE="SUPERNODE" \
  -p 10090:10090/udp \
  zctmdc/n2n_ntop
```

- 后台模式

```bash
docker run \
  -d --restart=always \
  --name=supernode_t1 \
  -e MODE="SUPERNODE" \
  -e SUPERNODE_PORT=10090 \
  -p 10090:10090/udp \
  zctmdc/n2n_ntop
```

### 建立 _edge_

- 前台模式

```bash
docker run \
  --rm -ti \
  --privileged \
  --net=host \
  -e MODE="DHCPD" \
  -e EDGE_IP="10.11.12.1" \
  -e EDGE_COMMUNITY="n2n" \
  -e EDGE_KEY="test" \
  -e SUPERNODE_HOST=127.0.0.1 \
  -e SUPERNODE_PORT=10090 \
  -e EDGE_ENCRYPTION=A3 \
  -e EDGE_TUN=edge_dhcpd_t1 \
  zctmdc/n2n_ntop
```

- 后台模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge_dhcpc_t1 \
  --privileged  \
  --net=host \
  -e MODE="DHCPC" \
  -e EDGE_COMMUNITY="n2n" \
  -e EDGE_KEY="test" \
  -e SUPERNODE_HOST=127.0.0.1 \
  -e SUPERNODE_PORT=10090 \
  -e EDGE_ENCRYPTION=A3 \
  -e EDGE_TUN=edge_dhcpc_t1  \
  zctmdc/n2n_ntop
```

- test

```bash
docker exec -ti n2n_edge_dhcpc_t1 ifconfig edge_dhcpc_t1
```

## 更多模式

### SUPERNODE - 超级节点

```bash
docker run \
  -d --restart=always \
  --name=supernode_t2 \
  -e MODE="SUPERNODE" \
  -e SUPERNODE_PORT=10090 \
  -p 10090:10090/udp \
  zctmdc/n2n_ntop
```

### DHCPD - DHCP 服务端模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge_dhcpd_t2 \
  --privileged \
  --net=host \
  -e MODE="DHCPD" \
  -e EDGE_IP="10.21.22.1" \
  -e EDGE_COMMUNITY="n2n" \
  -e EDGE_KEY="test" \
  -e SUPERNODE_HOST=127.0.0.1 \
  -e SUPERNODE_PORT=10090 \
  -e EDGE_ENCRYPTION=A3 \
  -e EDGE_TUN=edge_dhcpd_t2 \
  zctmdc/n2n_ntop
```

如果你需要自定义 DHCPD 服务配置文件

```bash
-v path/to/dhcpd.conf:/etc/dhcp/dhcpd.conf:ro \
```

### DHCPC - DHCP 动态 IP 模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge_dhcpc_t2 \
  --privileged \
  --net=host \
  -e MODE="DHCPC" \
  -e EDGE_COMMUNITY="n2n" \
  -e EDGE_KEY="test" \
  -e SUPERNODE_HOST=127.0.0.1 \
  -e SUPERNODE_PORT=10090 \
  -e EDGE_ENCRYPTION=A3 \
  -e EDGE_TUN=edge_dhcpc_t2 \
  zctmdc/n2n_ntop
```

### STATIC - 静态 IP 模式

```bash
docker run \
  -d --restart=always \
  --name n2n_edge_static_t2 \
  --privileged \
  --net=host \
  -e MODE="STATIC" \
  -e EDGE_IP="10.21.22.23" \
  -e EDGE_COMMUNITY="n2n" \
  -e EDGE_KEY="test" \
  -e SUPERNODE_HOST=127.0.0.1 \
  -e SUPERNODE_PORT=10090 \
  -e EDGE_ENCRYPTION=A3 \
  -e EDGE_TUN=edge_static_t2 \
  zctmdc/n2n_ntop
```

## 使用 _docker compose_ 配置运行

see: <docker-compose.yaml>

```bash
# docker compose build #编译

docker compose up n2n_edge_dhcpc #前台运行 n2n_edge_dhcpc 依赖项将启动
docker compose exec n2n_edge_dhcpc busybox ping  10.31.32.1 # 测试
docker compose down
```

## 环境变量介绍

|          变量名 | 变量说明              | 备注                     | 对应参数                                                                                                    |
| --------------: | :-------------------- | :----------------------- | :---------------------------------------------------------------------------------------------------------- |
|            MODE | 模式                  | 对应启动的模式           | _`SUPERNODE`_ _`DHCPD`_ _`DHCPC`_ _`STATIC`_                                                                |
|  SUPERNODE_PORT | 超级节点端口          | 在 SUPERNODE/EDGE 中使用 | -l $SUPERNODE_PORT                                                                                          |
|  SUPERNODE_HOST | 要连接的 N2N 超级节点 | IP/HOST                  | -l $SUPERNODE_HOST:$SUPERNODE_PORT                                                                          |
|         EDGE_IP | 静态 IP               | 在静态模式和 DHCPD 使用  | -a $EDGE_IP                                                                                                 |
|  EDGE_COMMUNITY | 组网名称              | 在 EDGE 中使用           | -c $EDGE_COMMUNITY                                                                                          |
|        EDGE_KEY | 组网密码              | 在 EDGE 中使用           | -k $EDGE_KEY                                                                                                |
| EDGE_ENCRYPTION | 加密方式              | edge 间连接加密方式      | -A1 = disabled, -A2 = Twofish (default), -A3 or -A (deprecated) = AES-CBC, -A4 = ChaCha20, -A5 = Speck-CTR. |
|        EDGE_TUN | 网卡名                | edge 使用的网卡名        | -d $EDGE_TUN                                                                                                |
|        N2N_ARGS | 更多参数              | 运行时附加的更多参数     | -v -f                                                                                                       |
|  USE_DEFALT_ARG | 默认参数              | 运行时附加的默认参数     | `false` / `true` ：`v1:-br` , `v2:-EfrA` , `v2s:--bfr -L auto` , `v3:-Efr -e auto`                          |

更多帮助请参考 [好运博客][好运博客] 中 [N2N 新手向导及最新信息][n2n 新手向导及最新信息] , [N2N 支持参数版本一览表][n2n_args]

中文说明参考: [附加参数](https://bugxia.com/?s=附加参数) , [点对网](https://bugxia.com/?s=点对网）)

更多节点请访问 [N2N 中心节点][n2n中心节点]

更多 Docker 介绍请访问 [docker-compose CLI 概述][overview of docker-compose cli] , [Docker 运行参考](https://docs.docker.com/engine/reference/run/)

## 告诉我你在用

如果你使用正常了请点个赞
[我的 docker 主页][zctmdc—docker] ，[n2n_ntop 的 docker 项目页][n2n_ntop] 和 [我 github 的 docker 项目页][zctmdc—github]
我将引起注意，不再随意的去更改和重命名空间/变量名

[n2n]: https://www.ntop.org/products/n2n/ "n2n官网"
[ntop]: https://github.com/ntop "ntop团队"
[好运博客]: http://www.lucktu.com "好运博客"
[n2n 新手向导及最新信息]: http://www.lucktu.com/archives/783.html "N2N 新手向导及最新信息（2019-12-05 更新）"
[n2n中心节点]: http://supernode.ml/ "N2N中心节点"
[组网示意]: ./img/n2n_network.png "组网示意"
[连接原理]: ./img/n2n_com.png "连接原理"
[zctmdc—docker]: https://hub.docker.com/u/zctmdc "我的docker主页"
[n2n_ntop]: https://hub.docker.com/r/zctmdc/n2n_ntop "n2n_ntop的docker项目页"
[zctmdc—github]: https://github.com/zctmdc/docker.git "我github的docker项目页"
[overview of docker-compose cli]: https://docs.docker.com/compose/reference/overview/ "docker-compose CLI概述"
[n2n_args]: https://github.com/lucktu/n2n "N2N 支持参数版本一览表"
