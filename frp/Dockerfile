FROM golang:alpine as buildDeps
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --update --no-cache tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del tzdata

RUN set -x \
  && apk add --update --no-cache git make

RUN git clone https://github.com/fatedier/frp.git /tmp/frp/ 

WORKDIR /tmp/frp

RUN go env -w GOPROXY=https://goproxy.cn \
  && make \
  && echo "frp version: `/tmp/frp/bin/frps --version`"

FROM alpine

LABEL zctmdc <zctmdc@outlook.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN set -x \
  && apk add --update --no-cache bash psmisc curl  
  # wget 

RUN  mkdir -p /etc/frp

COPY *.sh /usr/local/bin/
COPY --from=buildDeps /tmp/frp/bin/frps  /usr/local/bin/frps
COPY --from=buildDeps /tmp/frp/bin/frpc  /usr/local/bin/frpc
RUN chmod a+x /usr/local/bin/*

# 启用FRPC
ENV FRPC_ENABLE true

# 启用FRPS
ENV FRPS_ENABLE true

# 下载最新版本
ENV DOWN_LATEST false

# 检查状态
ENV WATCH_STATUS false

# string 鉴权使用的 token 值 客户端需要设置一样的值才能鉴权通过
ENV token abcd1234

# TCP流多路复用
ENV tcp_mux false

# string 日志文件地址 ./frps.log 如果设置为 console，会将日志打印在标准输出中
ENV log_file console

# string 日志等级 trace, debug, info, warn, error
ENV log_level info

# int 日志文件保留天数
ENV log_max_days 3


### FRPS ###

# 基础配置 #

# string 服务端监听地址
ENV bind_addr 0.0.0.0

# int 服务端监听端口 接收 frpc 的连接
ENV bind_port 7000

# int 服务端监听KCP协议端口 用于接收采用 KCP 连接的 frpc
ENV kcp_bind_port 7000

# int 服务端监听UDP端口 用于辅助创建 P2P 连接
ENV bind_udp_port 7001

# Dashboard, 监控 #

# string 启用 Dashboard 监听的本地地址
ENV dashboard_addr 0.0.0.0

# int 启用 Dashboard 监听的本地端口
ENV dashboard_port 7088

# string HTTP BasicAuth 用户名
ENV dashboard_user admin

# string HTTP BasicAuth 密码
ENV dashboard_pwd admin

# HTTP & HTTPS #

# int 为 HTTP 类型代理监听的端口 启用后才支持 HTTP 类型的代理，默认不启用
ENV vhost_http_port 7080

# int 为 HTTPS 类型代理监听的端口 启用后才支持 HTTPS 类型的代理，默认不启用
ENV vhost_https_port 7443

# string 二级域名后缀
ENV subdomain_host ""

### FRPC ###

# 基础配置 #
# string 连接服务端的地址
ENV server_addr localhost

# int 连接服务端的端口
ENV server_port 7000

# string 用户名 设置此参数后，代理名称会被修改为 {user}.{proxyName}，避免代理名称和其他用户冲突
ENV user ""

# string 连接服务端的通信协议 tcp, kcp, websocket
ENV protocol tcp

# AdminUI #

# string 启用 AdminUI 监听的本地地址
ENV admin_addr 0.0.0.0

# int 启用 AdminUI 监听的本地端口
ENV admin_port 7089

# string HTTP BasicAuth 用户名
ENV admin_user admin

# string HTTP BasicAuth 密码
ENV admin_pwd admin

CMD ["/bin/bash", "-c", "/usr/local/bin/run.sh"]

HEALTHCHECK --interval=30s --timeout=5s CMD /usr/local/bin/healthcheck_frpc.sh
