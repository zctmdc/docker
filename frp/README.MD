# FRP

frp 是一个专注于内网穿透的高性能的反向代理应用，支持 TCP、UDP、HTTP、HTTPS 等多种协议。可以将内网服务以安全、便捷的方式通过具有公网 IP 节点的中转暴露到公网。

## 其他镜像

官方: [fatedier/frps - Docker Image | Docker Hub](https://hub.docker.com/r/fatedier/frps)

雪梦科技: [snowdreamtech/frpc - Docker Image | Docker Hub](https://hub.docker.com/r/snowdreamtech/frpc)

## 启动

### 快速启动 FRPS

- docker cli

  ```bash
  docker run -ti --rm --network host -e SUBDOMAIN_HOST=frp.example.org zctmdc/frp:Alpha RUN_FRPS
  ```

- docker-compose

  ```yaml
  frps-demo:
    image: zctmdc/frp:alpha
    container_name: frps-demo
    restart: unless-stopped
    environment:
      - SUBDOMAIN_HOST=frp.example.org
      - MODE=RUN_FRPS
    network_mode: host
    # networks:
    #     net:
    # ports:
    #     - 7000:7000/tcp
    #     - 7000:7000/udp
    #     - 7001:7001/tcp
    #     - 7001:7001/udp
    #     - 7400:7400/tcp
  ```

打开控制台
在浏览器中输入 [http://localhost:7400](http://localhost:7400)
用户为 `admin`
密码为 `admin`

### 快速启动 FRPC

- docker cli

  ```bash
  docker run -ti --rm -e MODE=RUN_FRPC -e SUBDOMAIN_HOST=frp.example.org -p 7500:7400 zctmdc/frp:Alpha
  ```

- docker-compose

  ```yaml
  frpc-demo:
    image: zctmdc/frp:alpha
    container_name: frpc-demo
    restart: unless-stopped
    environment:
      - SUBDOMAIN_HOST=frp.example.org
      - MODE=RUN_FRPC
      - ADMIN_PORT=7400
    # network_mode: host
    networks:
      net:
    ports:
      - 7500:7400/tcp
  ```

在浏览器中输入 [http://localhost:7500](http://localhost:7500)
或者访问 [http://frp.example.org:7400/static/#/proxies/http](http://frp.example.org:7500/static/#/proxies/http)
用户为 `admin`
密码为 `admin`
点击 `Configure`，修改 frpc 配置后点击 `upload` 生效。

## 配置

### 本地配置文件

- 推荐使用 [其他镜像](##其他镜像)

默认配置文件位置为`/opt/frp/bak/`, 挂载自己的配置**目录**，覆盖默认配置文件。

- see: [docker-entrypoint.sh](https://github.com/zctmdc/docker/blob/alpha/frp/scripts/docker-entrypoint.sh#150)

```shell
    -v /you/conf/path/:/opt/frp/bak/
```

```yaml
volumes:
  - /you/conf/path/:/opt/frp/bak/
```

- 在容器 **启动** 时，将进行一次还原 **默认配置文件** `/opt/frp/bak/` `/etc/frp/`

以下情况除外

- 从网页修改过配置文件 [通过 frpc 远程配置](###通过frpc远程配置)

  即：配置文件不存在字符串 `Envs.SUBDOMAIN_HOST` `/etc/frp/`

```bash
CONF_FRPS=/etc/frp/frps.ini
CONF_FRPC=/etc/frp/frpc.ini

CONF_FRPS_BAK=/opt/frp/bak/frps.ini
CONF_FRPC_BAK=/opt/frp/bak/frpc.ini

CONF_FILE=$CONF_FRPC
CONF_FILE_BAK=$CONF_FRPC_BAK

if is_not_edit_pass_web && -f ${CONF_FILE}; then
    # 还原配置文件
    cp $CONF_FILE_BAK $CONF_FILE
    chmod +w $CONF_FILE
fi

```

### 附加配置文件

see: [docker-entrypoint.sh](https://github.com/zctmdc/docker/blob/alpha/frp/scripts/docker-entrypoint.sh#156)

```shell
    -v /you/conf/path/:/opt/frp/conf/
```

```yaml
volumes:
  - /you/conf/path/:/opt/frp/conf/
```

- 注意，检测到**附加配置文件**时，将会对 `/etc/frp/` 进行修改！
- **附加配置文件** 会附加在 **默认配置文件尾部**

以下情况除外

- 从网页修改过配置文件 [通过 frpc 远程配置](###通过frpc远程配置)

  即：配置文件不存在字符串 `Envs.SUBDOMAIN_HOST` `/etc/frp/`

```bash
CONF_FRPS=/etc/frp/frps.ini
CONF_FRPC=/etc/frp/frpc.ini

CONF_FRPS_ADD=/opt/frp/conf/frps_add.ini
CONF_FRPC_ADD=/opt/frp/conf/frpc_add.ini

CONF_ADD_PATH=/opt/frp/conf/add/

CONF_FILE=$CONF_FRPC
CONF_FILE_ADD=$CONF_FRPC_ADD

if is_not_edit_pass_web && -r ${CONF_FILE_ADD}; then
    # 拼接配置文件
    echo '' >>$CONF_FILE
    echo "$FLAG_CONF_ADD" >>$CONF_FILE
    echo '' >>$CONF_FILE
    cat $CONF_FILE_ADD >>$CONF_FILE
    echo '' >>$CONF_FILE
fi
if is_not_edit_pass_web && -r ${CONF_ADD_PATH}; then
    for src_file in $(find "${CONF_ADD_PATH}" -name '*.ini'); do
        if [ ! -r "$src_file" ]; then
            continue
        fi
        # 拼接配置文件
        echo '' >>$CONF_FILE
        echo "$FLAG_CONF_ADD" >>$CONF_FILE
        echo '' >>$CONF_FILE
        cat "$src_file" >>$CONF_FILE
        echo '' >>$CONF_FILE
    done
fi
```

### 在线配置

通过在线修改重启后，你可以在 `/etc/frp` 找到你的备份，请及时清理

#### Pass_FRPC

1. 访问 [https?://${客户端域名/IP}:${服务端口}/static/#/proxies/http](http://127.0.0.1:7400/static/#/proxies/http) `admin_port` `ADMIN_PORT`

2. 使用客户端账号密码登录 `admin_user` `admin_pwd` `ADMIN_USER` `ADMIN_PWD`

3. 点击 `Configure` ，进行相关配置

```ini
[http_admin_UI]
    type = http
    subdomain = {{ .Envs.HOSTNAME }}-admin
    local_ip = localhost
    local_port = {{ .Envs.ADMIN_PORT }}
```

#### Pass_FRPS

1. 访问 [https?://${服务端域名/IP}:${服务端口}/static/#/proxies/http](http://frp.example.org:7400/static/#/proxies/http) `SUBDOMAIN_HOST` `dashboard_port` `ADMIN_PORT`

2. 使用服务端账号密码登录 `dashboard_user` `dashboard_pwd` `ADMIN_USER` `ADMIN_PWD`

3. 找到 `-admin` 结尾的名称

4. 访问 `xxx-admin.服务端域名` `SUBDOMAIN_HOST`

5. 同 [Pass_FRPC](####Pass_FRPC)

### 通过 frpc 远程配置

1. 在服务端启动 `frps`，确保所有的客户端可以访问该主机。
2. 在被访问端启动 `frpc` `remote frpc`
3. 在访问客端启动 `frpc` `local frpc`
4. 配置访问端 `frpc`

- stcp

  - remote

    ```ini
    [stcp_admin_UI]
    type = stcp
    sk = {{ .Envs.SK }}
    local_ip = localhost
    local_port = {{ .Envs.ADMIN_PORT }}
    ```

  - lcocal

    ```ini
    [stcp_admin_UI_visitor]
    role = visitor
    type = stcp
    server_name = {{ .Envs.HOSTNAME }}.stcp_admin_UI
    sk = {{ .Envs.SK }}
    bind_addr = localhost
    bind_port = 9000
    ```

- xtcp

  - remote

    ```ini
    [p2p_admin_UI]
    type = xtcp
    sk = {{ .Envs.SK }}
    local_ip = localhost
    local_port = {{ .Envs.ADMIN_PORT }}
    ```

  - lcocal

    ```ini
    [p2p_admin_UI_visitor]
    role = visitor
    type = xtcp
    server_name = {{ .Envs.HOSTNAME }}.p2p_admin_UI
    sk = {{ .Envs.SK }}
    bind_addr = localhost
    bind_port = 9001
    ```

### 容器环境变量说明

| 环境变量名       |          类型/限制          | 说明                                                        |   默认值    |
| :--------------- | :-------------------------: | :---------------------------------------------------------- | :---------: |
| SUBDOMAIN_HOST   |           string            | 二级域名后缀/服务器地址                                     | `localhost` |
| BIND_PORT        |             int             | 服务端监听端口, 接收 `frpc` 的连接                          |   `7000`    |
| BIND_UDP_PORT    |             int             | 服务端监听 `KCP` 协议端口, 用于接收采用 `KCP` 连接的 frpc   |   `7001`    |
| TOKEN            |           string            | 鉴权使用的 token 值 客户端需要设置一样的值才能鉴权通过      | `12345678`  |
| VHOST_HTTP_PORT  |             int             | `HTTP` 类型代理监听的端口, 启用后才支持 `HTTP` 类型的代理   |    `80`     |
| VHOST_HTTPS_PORT |             int             | `HTTPS` 类型代理监听的端口, 启用后才支持 `HTTPS` 类型的代理 |    `443`    |
| PROTOCOL         | `tcp` / `kcp` / `websocket` | 用于连接到服务器的通信协议                                  |    `kcp`    |
| ADMIN_ADDR       |           string            | 启用 `AdminUI` 监听的本地地址                               |  `0.0.0.0`  |
| ADMIN_PORT       |             int             | 启用 `AdminUI` 监听的本地端口                               |   `7400`    |
| ADMIN_USER       |           string            | `HTTP BasicAuth` 用户名                                     |   `admin`   |
| ADMIN_PWD        |           string            | `HTTP BasicAuth` 密码                                       |   `admin`   |
| SK               |           string            | `stcp`/`xtcp` 验证码                                        |  `abcdefg`  |
| MODE             |   `RUN_FRPC` / `RUN_FRPS`   | 启动模式                                                    | `RUN_FRPC`  |

## 自定义配置文件启动

使用 [其他镜像](#其他镜像 "其他镜像")

## 官方文档

项目官网: [https://github.com/fatedier/frp](https://github.com/fatedier/frp)

文档官网: [https://gofrp.org/docs/](https://gofrp.org/docs/)

客户端配置: [https://gofrp.org/docs/reference/client-configures/](https://gofrp.org/docs/reference/client-configures/)

服务端配置: [https://gofrp.org/docs/reference/server-configures/](https://gofrp.org/docs/reference/server-configures/)

示例：[https://gofrp.org/docs/examples/](https://gofrp.org/docs/examples/)
