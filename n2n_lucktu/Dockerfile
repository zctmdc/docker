FROM debian:buster-slim as downloader

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -yq \
  bash curl wget unzip jq
ADD https://www.rarlab.com/rar/unrar_5.2.5-0.1_amd64.deb /tmp/rar/
RUN dpkg -i /tmp/rar/unrar_5.2.5-0.1_amd64.deb

ARG KERNEL=linux
ARG MACHINE=x64
ARG BIG_VERSION=v2
ARG SMALL_VERSION=3.1.1-16
ARG COMMITS=r1200

WORKDIR /tmp/scripts/
COPY ./scripts/*.sh /tmp/scripts/
RUN chmod +x /tmp/scripts/*.sh
RUN bash -c /tmp/scripts/down_n2n.sh

FROM debian:buster-slim

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -yq \
  net-tools iputils-ping traceroute iptables

COPY --from=downloader \
  /tmp/n2n/supernode \
  /tmp/n2n/edge \
  /usr/local/sbin/

COPY ./scripts/*.sh /usr/local/sbin/

CMD [ "/bin/bash" , "-c" , "/usr/local/sbin/run.sh" ]

HEALTHCHECK --interval=20s --timeout=10s CMD /usr/local/sbin/n2n_healthcheck.sh
