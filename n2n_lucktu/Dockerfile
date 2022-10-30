FROM debian:buster-slim as downloader

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -yq \
  bash curl wget unzip jq


WORKDIR /tmp/scripts/
COPY ./scripts/*.sh /tmp/scripts/
RUN chmod +x /tmp/scripts/*.sh

ARG KERNEL=linux
ARG MACHINE
ARG BIG_VERSION=v2
ARG SMALL_VERSION=3.1.1-16
ARG COMMITS=r1200

RUN bash -c install_rar.sh
RUN bash -c /tmp/scripts/down_n2n.sh

FROM debian:buster-slim

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -yq \
  net-tools iputils-ping traceroute iptables

COPY --from=downloader \
  /tmp/n2n/supernode \
  /tmp/n2n/edge \
  /usr/local/sbin/

COPY ./scripts/*.sh /usr/local/sbin/

CMD [ "/bin/bash" , "-c" , "/usr/local/sbin/run_n2n.sh" ]

HEALTHCHECK --interval=20s --timeout=10s CMD /usr/local/sbin/n2n_healthcheck.sh
