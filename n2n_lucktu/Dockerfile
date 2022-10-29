FROM debian:buster-slim as downloader

ARG DEBIAN_FRONTEND=noninteractive
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list
RUN apt-get update && apt-get install -yq \
  bash curl wget unzip jq
ADD https://www.rarlab.com/rar/unrar_5.2.5-0.1_amd64.deb /tmp/rar/
RUN dpkg -i /tmp/rar/unrar_5.2.5-0.1_amd64.deb

ARG KERNEL=linux
ARG MACHINE=x64
ARG BIG_VERSION=v2
ARG SMALL_VERSION=3.1.1-16
ARG COMMITS=r1200

WORKDIR /tmp/cmd/
COPY *.sh /tmp/cmd/
RUN chmod +x /tmp/cmd/*.sh
RUN bash -c /tmp/cmd/down_n2n.sh

FROM debian:buster-slim

# ARG DEBIAN_FRONTEND=noninteractive
# RUN apt-get update && apt-get -yq upgrade
# RUN apt-get -yq install \
#   apt-utils tzdata \
#   && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
#   && echo "Asia/Shanghai" > /etc/timezone \
#   && dpkg-reconfigure -f tzdata
# ##################-----##################

# RUN apt-get install -yq \
#   wget openssl isc-dhcp-client isc-dhcp-server net-tools iputils-ping \
#   curl  ca-certificates traceroute htop psmisc iptables \
#   && rm -rf /etc/dhcp/dhcpd.conf

# ##################-----##################
# RUN apt-get clean

# RUN mkdir -p /usr/local/sbin/

COPY --from=downloader \
  /tmp/n2n/supernode \
  /tmp/n2n/edge \
  /usr/local/sbin/

# COPY *.sh /usr/local/sbin/

# RUN set -x \
#   && chmod a+x /usr/local/sbin/*

ENV MODE SUPERNODE

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

HEALTHCHECK --interval=20s --timeout=10s CMD /usr/local/sbin/n2n_healthcheck.sh
