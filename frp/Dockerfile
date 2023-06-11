ARG DOCKER_TAG=latest
FROM snowdreamtech/frpc:${DOCKER_TAG} as frpc_src
FROM snowdreamtech/frps:${DOCKER_TAG} as frps_src

FROM alpine
RUN apk add --update --no-cache tzdata curl bash \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del tzdata
RUN mkdir -p /usr/share/zoneinfo/Asia/ \
  && ln -s /etc/localtime /usr/share/zoneinfo/Asia/Shanghai
##################-----##################

##################-----##################
RUN rm -rf /var/cache/apk/*

COPY --from=frpc_src  /usr/bin/frpc  /usr/bin/frpc
COPY --from=frps_src  /usr/bin/frps  /usr/bin/frps

RUN chmod a+x /usr/bin/frpc /usr/bin/frps

WORKDIR /opt/frp/
RUN mkdir -p /opt/frp/bak/
COPY ./config/*  /opt/frp/bak/
RUN chmod a-w /opt/frp/bak/*

COPY ./scripts/* /opt/frp/

RUN ln -s /usr/bin/frps /opt/frp/fprs \
  && ln -s /usr/bin/frpc /opt/frp/fprc

RUN chmod a+x /opt/frp/*

# string 二级域名后缀/服务器地址
ENV SUBDOMAIN_HOST=localhost
# int 服务端监听端口 接收 frpc 的连接
ENV BIND_PORT=7000
# int 服务端监听KCP协议端口 用于接收采用 KCP 连接的 frpc
ENV BIND_UDP_PORT=7001
# string 鉴权使用的 token 值 客户端需要设置一样的值才能鉴权通过
ENV TOKEN=12345678

# int 为 HTTP 类型代理监听的端口 启用后才支持 HTTP 类型的代理，默认不启用
ENV VHOST_HTTP_PORT=80
# int 为 HTTPS 类型代理监听的端口 启用后才支持 HTTPS 类型的代理，默认不启用
ENV VHOST_HTTPS_PORT=443
# tcp|kcp|websocket 用于连接到服务器的通信协议
ENV PROTOCOL=kcp
# string 启用 AdminUI 监听的本地地址
ENV ADMIN_ADDR=0.0.0.0
# int 启用 AdminUI 监听的本地端口
ENV ADMIN_PORT=7400
# string HTTP BasicAuth 用户名
ENV ADMIN_USER=admin
# string HTTP BasicAuth 密码
ENV ADMIN_PWD=admin
# stcp/xtcp 验证码
ENV SK=abcdefg

# RUN_FRPS/RUN_FRPS
ENV MODE=RUN_FRPC

VOLUME /etc/frp/
VOLUME /opt/frp/conf/

ENTRYPOINT ["/opt/frp/docker-entrypoint.sh"]
HEALTHCHECK --interval=30s --timeout=10s CMD curl -s --head "http://localhost:${ADMIN_PORT}/healthz" || exit 1