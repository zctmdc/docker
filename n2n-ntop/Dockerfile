FROM alpine AS build-env

MAINTAINER zctmdc <zctmdc@outlook.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
############start build############
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
	&& apk update \ 
	&& apk upgrade \ 
	&& apk add --update --no-cache --virtual .build-deps $buildDeps \
	&& git clone https://github.com/ntop/n2n.git \
  && cd n2n \
  && cmake . \
	&& make install \
	&& cd /tmp \
	&& rm -rf ./* \
	&& apk del .build-deps
############end build############

ENV MODE DHCP
ENV SUPERNODE_PORT 10086
ENV N2N_INTERFACE edge0
ENV STATIC_IP 10.0.0.10
ENV N2N_GROUP zctmdc_dhcp
ENV N2N_PASS zctmdc_dhcp
ENV N2N_SERVER n2n.lucktu.com:10086

RUN apk add --update --no-cache openssl dhclient dhcp-server-ldap \
	&& touch /var/lib/dhcp/dhcpd.leases \
	&& touch /var/log/run.log

COPY dhcpd.conf  /etc/dhcp/dhcpd.conf
COPY run.sh /user/sbin/run.sh

CMD ["/bin/sh","-c","/user/sbin/run.sh"]