FROM debian

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/ports.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

RUN sed -i 's/snapshot.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y --no-install-recommends tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata \
  && apt-get clean

RUN apt-get update \
  && apt-get install -y --no-install-recommends wget openssl \
  isc-dhcp-client isc-dhcp-server net-tools iputils-ping \
  curl traceroute htop psmisc iptables  apt-utils \
  && rm -rf /etc/dhcp/dhcpd.conf \
  && apt-get clean 

# COPY --from=builder /usr/local/bin/n2n-benchmark /usr/local/sbin/
# COPY --from=builder /usr/local/sbin/supernode /usr/local/sbin/
# COPY --from=builder /usr/local/sbin/edge /usr/local/sbin/

RUN mkdir -p /usr/local/sbin/

COPY *.sh /usr/local/sbin/

RUN chmod a+x /usr/local/sbin/* \
  && . /usr/local/sbin/init.sh \
  && wget -O /usr/local/sbin/edge http://rt.qiniu.zctmdc.cn/bin/edge_v2_${myos}_${mycpu} \
  && wget -O /usr/local/sbin/supernode http://rt.qiniu.zctmdc.cn/bin/supernode_v2_${myos}_${mycpu}

RUN set -x \
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

HEALTHCHECK --interval=20s --timeout=10s CMD /usr/local/sbin/n2n_healthcheck.sh
