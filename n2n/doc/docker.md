# docker n2n

## 关于

[n2n][n2n] 是一个 **第二层对等 VPN**，可轻松创建绕过中间防火墙的虚拟网络。

通过编译 [ntop 团队][ntop] 发布的 n2n,直连成功率高(仅局域网内不及), 且速度更快.

N2N 是通过 UDP 方式建立链接，如果某个网络禁用了 UDP，那么该网络下的设备就不适合使用本软件来加入这个虚拟局域网（用"blue's port scanner"，选择 UDP 来扫描，扫出来的就是未被封的，正常情况下应该超级多）

为了开始使用 N2N，需要两个元素：

1. _supernode_ ：

    - 它允许 edge 节点链接和发现其他 edge 的超级节点。

    - 它必须具有可在公网上公开端口。

2. _edge_ ：将成为虚拟网络一部分的节点;

    - 在 n2n 中的多个边缘节点之间共享的虚拟网络称为 community。

单个 supernode 节点可以中继多个 edge ，而单个电脑可以同时连接多个 supernode。
边缘节点可以使用加密密钥对社区中的数据包进行加密。
n2n 尽可能在 edge 节点之间建立直接的 P2P 连接;如果不可能（通常是由于特殊的 NAT 设备），则超级节点也用于中继数据包。

### 组网示意

![组网示意][组网示意]

### 连接原理

![连接原理][连接原理]

## 快速入门

### 代码换行

通过以下符号分行,你可以分行输入你需要运行的代码

|       终端 |  符号  | 按键方法                                  |
| ---------: | :----: | :---------------------------------------- |
|       bash | **\\** | <kbd>\\</kbd> 位于<kbd>Enter</kbd> 键上方 |
| powershell | **`**  | <kbd>\`</kbd> 位于 <kbd>TAB</kbd> 键上方  |
|        CMD | **＾** | <kbd>Shift</kbd>+<kbd>6</kbd>             |

### 建立 _supernode_

-   前台模式

    ```bash
    docker run \
    -ti --rm \
    -p 10090:10090/udp \
    zctmdc/n2n \
    supernode -p 10090 -vf
    ```

-   后台模式

    ```bash
    docker run \
    -d --restart=always \
    --name=supernode \
    -p 10090:10090/udp \
    zctmdc/n2n \
    supernode -p 10090 -vf
    ```

### 建立 _edge_

-   前台模式

    ```bash
    docker run \
    -ti --rm\
    --privileged \
    --net=host \
    zctmdc/n2n \
    edge -d T3 -a 172.3.0.77 -c n2n -k test -l 127.0.0.1:10090 -Efrv -e auto
    ```

-   后台模式

    ```bash
    docker run \
    -d --restart=always \
    --privileged \
    --net=host \
    --name=edge \
    zctmdc/n2n \
    edge -d T3 -a 172.3.0.78 -c n2n -k test -l 127.0.0.1:10090 -Efrv -e auto
    ```

-   测试

    `docker exec edge busybox ping 172.3.0.77`

### 使用配置文件

n2n 自 `v.2.3.0_r54` 开始，支持从配置文件中启动

[n2n on docker ][docker-n2n] 是通过魔改解析命令启动的。


> 以下演示为 v.2.9.0+

1. 创建配置文件

    ```bash
    mkdir -p config
    ```

    - cat FILE EOF

        ```bash
        cat >file<<-EOF
        文件内容-line1
        文件内容-line2
        文件内容-line3
        文件内容-line4
        EOF
        ```

        see: <https://cn.bing.com/search?q=cat+file+eof>
        mabe not work.

    - var

        ```bash
        content='
        文件内容-line1
        文件内容-line2
        文件内容-line3
        文件内容-line4
        '
        echo "${content}">file
        ```

    - `./config/supernode.conf`

        ```bash
        cat >./config/edge.conf<<-EOF
        # v.2.3.0_r54 < $VERSION_B_s_rC < v.2.9.0_r529
        # SUPERNODE_PORT
        # -l=10086
        # $VERSION_B_s_rC > v.2.9.0_r529
        -p=10090
        -f
        -v
        EOF
        ```

    - `./config/edge.conf`

        ```properties
        # 虚拟网卡名字
        -d T3
        # edge ip
        -a=172.3.0.77
        # community 名字
        -c=n2n
        # community 密码
        -k=test
        # supernode 地址和端口
        -l=127.0.0.1:10090
        # 使用 AES 加密算法加密传输的数据
        -A3
        # 作为首选播发提供的本地IP地址
        -e=auto
        # 允许多播mac地址
        -E
        # 允许edge直接的网络转发
        -r
        # 详细模式
        -v
        # 前台运行而不是后台
        -f

        ```

2. 挂载运行

    - supernode

        ```bash
        docker run \
          -d --restart=always \
          --name=supernode \
          -p 10090:10090/udp \
          -v $(pwd)/config/:/n2n/conf/ \
          zctmdc/n2n \
          supernode /n2n/conf/supernode.conf
        ```

    - edge

        ```bash
        docker run \
          -d --restart=always \
          --privileged \
          --net=host \
          --name=edge \
          -v $(pwd)/config/:/n2n/conf/ \
          zctmdc/n2n \
          edge /n2n/conf/edge.conf
        ```

[ntop/n2n 项目配置文件示例][github_n2n_conf]

[ntop/n2n 项目配置文件说明][github_n2n_conf_md]

### 使用 _docker-compose_ 配置运行

1. 创建配置文件

    - `./config/edge.conf`

    - `./config/supernode.conf`

    - `docker-compose.yaml`

        see: <https://github.com/zctmdc/docker/blob/alpha/n2n/docker-compose.yaml>

        ```yaml
        version: "3"
        services:
            n2n_supernode:
                # build:
                #   context: .
                #   dockerfile: Dockerfile
                image: zctmdc/n2n
                container_name: n2n_supernode
                restart: always
                volumes:
                    - ./config/:/n2n/conf/
                # command: ["supernode", "/n2n/conf/supernode.conf"]
                # privileged: true
                # network_mode: host
                ports:
                    - 10090:10090/udp
                networks:
                    n2n:
                        ipv4_address: 172.77.5.10

            n2n_edge_1:
                image: zctmdc/n2n
                container_name: n2n_edge_1
                restart: always
                privileged: true
                command:
                    [
                        "sh",
                        "-c",
                        "edge -d T3 -a 10.3.0.77 -c n2n -k test -l 172.77.5.10:10090 -e auto -Efrv",
                    ]
                # network_mode: host
                networks:
                    n2n: # ipv4_address: 172.77.5.11
                depends_on:
                    - n2n_supernode
                external_links:
                    - n2n_supernode:n2n_supernode

            n2n_edge_2:
                image: zctmdc/n2n
                container_name: n2n_edge_2
                restart: always
                privileged: true
                volumes:
                    - ./config/:/n2n/conf/
                # command: ["edge", "/n2n/conf/edge.conf"]
                # network_mode: host
                networks:
                    n2n:
                depends_on:
                    - n2n_supernode
                external_links:
                    - n2n_supernode:n2n_supernode

        networks:
            n2n:
                driver: bridge
                ipam:
                    driver: default
                    config:
                        - subnet: 172.77.5.0/24
        ```

2. 启动容器

    ```bash
    docker-compose up -d                          # 后台运行
    docker exec -ti n2n_edge_1 ping 10.3.0.78     # 运行指令
    # docker-compose up                           # 前台运行
    # docker-compose up n2n_edge_1                # 仅前台运行 n2n_edge_1
    # docker-compose up -d n2n_edge_1             # 仅后台运行 n2n_edge_1
    # docker-compose run n2n_edge_1 edge -h       # 运行指令
    ```

## 参数说明

不同版本间参数是不一样的，建议运行前使用 `-h` 或者 `--help` 命令查看。

中文说明参考: [附加参数](https://bugxia.com/?s=附加参数) , [点对网](https://bugxia.com/?s=点对网）)

在 [ntop/n2n 项目][github_n2n] **doc** 目录中有更多说明。

```bash
docker run \
  --rm \
  zctmdc/n2n \
  supernode -h
```

```bash
docker run \
  --rm \
  zctmdc/n2n \
  edge --help
```

-   更多本容器说明见 [build.md](build.md)

-   文档参见 [ntop/n2n 项目文档][github_n2n_doc]

-   更多帮助请参考 [好运博客][好运博客] 中 [N2N 新手向导及最新信息][n2n 新手向导及最新信息]

-   更多节点请访问 [N2N 中心节点][n2n中心节点]

更多介绍请访问 [docker-compose CLI 概述][overview of docker-compose cli]

## DHCP

内置多个软件包

-   `busybox`
-   `iptables`
-   `isc-dhcp-client`
-   `isc-dhcp-server`

参考官方的教程，网上说明，进行配置

-   `dhcpd -f -d "${EDGE_TUN}" -cf dhcpd.conf`
-   `busybox udhcpd udhcpd.conf`
-   `dhclient -d --dad-wait-time 5 ${EDGE_TUN}`
-   `busybox ip`
-   `iptables`

可以看看: <https://github.com/zctmdc/docker/blob/alpha/n2n/scripts/run/run_n2n.sh>

## 告诉我你在用

如果你使用正常了请点个赞

-   [我 github 的 docker 项目页][zctmdc_github]
-   [n2n 的 docker 项目页][docker-n2n]
-   [我 github 的 n2n docker 页][zctmdc_n2n]

我将引起注意，不再随意的去更改和重命名空间/变量名

[n2n]: https://www.ntop.org/products/n2n/ "n2n官网"
[github_n2n]: https://github.com/ntop/n2n "ntop/n2n 项目"
[github_n2n_doc]: https://github.com/ntop/n2n/tree/dev/doc "ntop/n2n 项目文档"
[github_n2n_conf]: https://github.com/ntop/n2n/tree/dev/packages/etc/n2n "ntop/n2n 项目配置文件示例"
[github_n2n_conf_md]: https://github.com/ntop/n2n/blob/dev/doc/Advanced.md "ntop/n2n 项目配置文件说明"
[ntop]: https://github.com/ntop "ntop团队"
[好运博客]: http://www.lucktu.com "好运博客"
[n2n 新手向导及最新信息]: http://www.lucktu.com/archives/783.html "N2N 新手向导及最新信息（2019-12-05 更新）"
[n2n中心节点]: http://supernode.ml/ "N2N中心节点"
[组网示意]: ../img/n2n_network.png "组网示意"
[连接原理]: ../img/n2n_com.png "连接原理"
[docker-n2n]: https://hub.docker.com/r/zctmdc/n2n/ "n2n的docker项目页"
[zctmdc_github]: https://github.com/zctmdc/docker.git "我github的docker项目页"
[zctmdc_n2n]: https://github.com/zctmdc/docker/blob/alpha/n2n/ "我github的n2n docker页"
[overview of docker-compose cli]: https://docs.docker.com/compose/reference/overview/ "docker-compose CLI概述"
 