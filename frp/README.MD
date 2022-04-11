# FRP

frp 是一个专注于内网穿透的高性能的反向代理应用，支持 TCP、UDP、HTTP、HTTPS 等多种协议。可以将内网服务以安全、便捷的方式通过具有公网 IP 节点的中转暴露到公网。

## 启动

### 快速启动 FRPS

```bash
 docker run -ti --rm --network host zctmdc/frp:Alpha frps -c /etc/frp/frps.ini
```

打开控制台
在浏览器中输入 <http://localhost:7500>
用户为 `admin`
密码为 `admin`

### 快速启动 FRPC

```bash
 docker run -ti --rm --network host zctmdc/frp:Alpha frpc -c /etc/frp/frpc.ini
```

在浏览器中输入 <http://localhost:7400>
或者访问<http://localhost:7500/static/#/proxies/http>
用户为 `admin`
密码为 `admin`
点击`Configure`，修改 frpc 配置后点击`upload`生效。

### 远程配置其他 FRPC
具体请参考https://gofrp.org/docs/examples/stcp/

1. 在服务端启动 `frps`，确保所有的客户端可以访问该主机。
2. 在被访问客户端启动 `frpc`
3. 访问 <http://服务端地址:7500/static/#/proxies/stcp> ，查看 `stcp` 服务名称 eg:`XXX.stcp_admin_UI`
4. 在本地客户端启动 `frpc` ，修改 `frpc` 配置中 `stcp_admin_UI_visitor` 的 `{{ .Envs.HOSTNAME }}` 为被访问客户端`stcp` 服务名称，注意移除注释符号。
5. 在浏览器输入 <http://localhost:9000/> 登录被访问客户端 `frpc` 控制面板，进行相关配置。 



### 使用自定义配置文件启动

```bash
docker run \
  -d \
  --restart always \
  --name frpc \
  --network host \
  -v /path/to/conf:/etc/frp/ \
  -e SUBDOMAIN_HOST="frp.zctmdc.cc" \
  zctmdc/frp:Alpha \
  /usr/sbin/frpc -c /etc/frp/frpc.ini
```

### 更多请看

更多配置参考: <https://github.com/zctmdc/docker>

## 官方文档

项目官网: <https://github.com/fatedier/frp>

文档官网: <https://gofrp.org/docs/>

客户端配置: <https://gofrp.org/docs/reference/client-configures/>

服务端配置: <https://gofrp.org/docs/reference/server-configures/>
