FROM alpine AS builder

MAINTAINER zctmdc <zctmdc@outlook.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

WORKDIR /tmp
RUN buildDeps=" \
    build-base \
    cmake \
    git \
    linux-headers \
    openssl-dev \
  "; \
  \
  set -x \
  && apk add --update --no-cache --virtual .build-deps $buildDeps \
  && git clone https://github.com/ntop/n2n.git \
  && cd n2n \
  && cmake . \
  && make install

FROM alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --update --no-cache openssl dhclient dhcp-server-ldap bash

COPY --from=builder /usr/local/bin/n2n-benchmark /usr/local/sbin/
COPY --from=builder /usr/local/sbin/supernode /usr/local/sbin/
COPY --from=builder /usr/local/sbin/edge /usr/local/sbin/
# COPY edge-dhcp-server/dhcpd.conf  /etc/dhcp/dhcpd.conf
COPY run.sh /usr/local/sbin/
COPY n2n.sh /usr/local/sbin/

RUN set -x \
  && chmod a+x /usr/local/sbin/run.sh \
  && chmod a+x /usr/local/sbin/n2n.sh \
  && touch /var/lib/dhcp/dhcpd.leases \
  && touch /var/log/n2n.log \
  && touch /var/log/run.log

ENV MODE DHCP
ENV N2N_PORT 10086
ENV N2N_TUN edge0
ENV N2N_IP 10.0.10.10
ENV N2N_COMMUNITY zctmdc_proxy
ENV N2N_KEY zctmdc_proxy
ENV N2N_SERVER n2n.lucktu.com:10086
ENV N2N_ARGS -Av
CMD [ "/bin/bash" , "-c" , "/usr/local/sbin/run.sh" ]
