# FROM alpine AS builder

# LABEL zctmdc <zctmdc@outlook.com>

# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
# # RUN sed -i 's/snapshot.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
# # RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# WORKDIR /tmp
# RUN buildDeps=" \
#     build-base \
#     cmake \
#     git \
#     linux-headers \
#     openssl-dev \
#     libpcap-dev \
#   "; \
#   \
#   set -x \
#   && apk add --update --no-cache --virtual .build-deps $buildDeps \
#   && git clone https://github.com/ntop/n2n.git \
#   && cd n2n \
#   && cmake . \
#   && make install

FROM alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --update --no-cache openssl dhclient dhcp-server-ldap bash

# COPY --from=builder /usr/local/bin/n2n-benchmark /usr/local/sbin/
# COPY --from=builder /usr/local/sbin/supernode /usr/local/sbin/
# COPY --from=builder /usr/local/sbin/edge /usr/local/sbin/

RUN mkdir -p /usr/local/sbin/
RUN wget -O /usr/local/sbin/edge http://rt.qiniu.zctmdc.cn/bin/edge_v2_linux_x86 
RUN wget -O /usr/local/sbin/supernode http://rt.qiniu.zctmdc.cn/bin/supernode_v2_linux_x86

COPY *.sh /usr/local/sbin/


RUN set -x \
  # && chmod a+x /usr/local/sbin/*.sh \
  && chmod a+x /usr/local/sbin/*

ENV MODE DHCP
ENV N2N_PORT 10086
ENV N2N_TUN edge0
ENV N2N_IP 10.10.10.10
ENV N2N_COMMUNITY n2n
ENV N2N_KEY test
ENV N2N_SERVER n2n.lucktu.com:10086
ENV N2N_ARGS -A -v
ENV TZ Asia/Shanghai
CMD [ "/bin/bash" , "-c" , "/usr/local/sbin/run.sh" ]
