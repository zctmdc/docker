FROM snowdreamtech/frpc as frpc_src
FROM snowdreamtech/frps as frps_src

FROM alpine

ARG name="frp"
ARG summary="frp 是一个专注于内网穿透的高性能的反向代理应用，支持 TCP、UDP、HTTP、HTTPS 等多种协议。可以将内网服务以安全、便捷的方式通过具有公网 IP 节点的中转暴露到公网。"
LABEL description="${summary}" \
  maintainer="<zctmdc@outlook.com>" \
  app.kubernetes.io/name="${name}" \
  org.opencontainers.image.title="${name}" \
  org.opencontainers.artifact.description="${summary}" \
  org.opencontainers.image.url="https://hub.docker.com/r/zctmdc/frp" \
  org.opencontainers.image.source="https://github.com/zctmdc/docker/tree/alpha/frp" \
  org.opencontainers.image.authors="zctmdc@outlook.com" \
  org.opencontainers.image.description="${summary}" \
  org.opencontainers.image.documentation="https://github.com/zctmdc/docker/tree/alpha/frp/README.MD"\
  org.opencontainers.image.licenses="Apache License 2.0"

RUN apk add --update --no-cache tzdata curl bash \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del tzdata
RUN mkdir -p /usr/share/zoneinfo/Asia/ \
  && ln -s /etc/localtime /usr/share/zoneinfo/Asia/Shanghai

COPY --from=frpc_src  /usr/bin/frpc  /usr/bin/frpc
COPY --from=frps_src  /usr/bin/frps  /usr/bin/frps

RUN chmod +x /usr/bin/frpc /usr/bin/frps

WORKDIR /opt/frp/

COPY ./config/*  /etc/frp/
COPY ./scripts/*  /opt/frp/

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

ENTRYPOINT ["/opt/frp/docker-entrypoint.sh"]
HEALTHCHECK --interval=30s --timeout=10s CMD curl --head "http://localhost:${ADMIN_PORT}/healthz" || exit 1