FROM debian:buster-slim as builder

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update

RUN apt-get -qq -y install \
  bash curl ca-certificates wget jq

WORKDIR /tmp/scripts/

COPY ./scripts/*.sh /tmp/scripts/

RUN chmod +x /tmp/scripts/*.sh

ARG KERNEL

ARG MACHINE

ARG FRP_VERSION

RUN /tmp/scripts/frp_download.sh


FROM debian:buster-slim

LABEL author=zctmdc
LABEL email=<zctmdc@outlook.com>

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update

RUN apt-get -qq -y install \
  apt-utils tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata
##################-----##################

RUN apt-get -qq -y install \
  bash curl ca-certificates procps

##################-----##################
RUN apt-get clean

RUN mkdir -p /etc/frp

COPY --from=builder \
  /tmp/frp/frps \
  /tmp/frp/frpc \
  /usr/sbin/

COPY ./config/*  /etc/frp/

RUN chmod +x /usr/sbin/frpc /usr/sbin/frps

# string 二级域名后缀/服务器地址
ENV SUBDOMAIN_HOST localhost
# int 服务端监听端口 接收 frpc 的连接
ENV BIND_PORT 7000
# int 服务端监听KCP协议端口 用于接收采用 KCP 连接的 frpc
ENV BIND_UDP_PORT 7001
# string 鉴权使用的 token 值 客户端需要设置一样的值才能鉴权通过
ENV TOKEN 12345678

# int 为 HTTP 类型代理监听的端口 启用后才支持 HTTP 类型的代理，默认不启用
ENV VHOST_HTTP_PORT 80
# int 为 HTTPS 类型代理监听的端口 启用后才支持 HTTPS 类型的代理，默认不启用
ENV VHOST_HTTPS_PORT 443
# tcp|kcp|websocket 用于连接到服务器的通信协议
ENV PROTOCOL kcp
# string 启用 AdminUI 监听的本地地址
ENV ADMIN_ADDR 0.0.0.0
# int 启用 AdminUI 监听的本地端口
ENV ADMIN_PORT 7400
# string HTTP BasicAuth 用户名
ENV ADMIN_USER admin
# string HTTP BasicAuth 密码
ENV ADMIN_PWD admin
# stcp、xtcp 验证码
ENV SK abcdefg

CMD [ "/bin/bash",  "-c",  "echo -e 'RUN FRPS\n  /usr/sbin/frps -c /etc/frp/frps.ini\nRUN FRPC\n  /usr/sbin/frps -c /etc/frp/frps.ini\nDEFAULT RUN FRPC\n' && /usr/sbin/frps -c /etc/frp/frps.ini" ]

# CMD ["/usr/sbin/frps", "-c", "/etc/frp/frps.ini"]
# CMD ["/usr/sbin/frpc", "-c", "/etc/frp/frpc.ini"]


COPY ./healthcheck/ /opt/healthcheck/
RUN chmod +x  /opt/healthcheck/*.sh 
# HEALTHCHECK --interval=30s --timeout=10s CMD /opt/healthcheck/healthcheck.sh || exit 1
