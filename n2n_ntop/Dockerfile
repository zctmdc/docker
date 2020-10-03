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

ENV N2N_ARGS "-v -f"

ENV SUPERNODE_HOST n2n.lucktu.com
ENV SUPERNODE_PORT 10086

ENV EDGE_IP 10.10.10.10
ENV EDGE_NETMASK 255.255.255.0
ENV EDGE_COMMUNITY n2n
ENV EDGE_KEY test
ENV EDGE_TUN edge0
ENV EDGE_ENCRYPTION A3
ENV EDGE_REG_INTERVAL 5
ENV EDGE_MTU 1290
ENV EDGE_UDP_PORT ""

CMD [ "/bin/bash" , "-c" , "/usr/local/sbin/run.sh" ]

HEALTHCHECK --interval=5s --timeout=2s CMD /usr/local/sbin/n2n_healthcheck.sh