FROM debian:buster-slim as downloader

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update

RUN apt-get -qq -y install \
  bash curl wget unzip jq


WORKDIR /tmp/scripts/
COPY ./scripts/*.sh /tmp/scripts/
RUN chmod +x /tmp/scripts/*.sh

ARG KERNEL=linux
ARG MACHINE
ARG BIG_VERSION=v2
ARG SMALL_VERSION=3.1.1-16
ARG COMMITS=r1200

RUN /tmp/scripts/install_rar.sh
RUN /tmp/scripts/get_n2n.sh

FROM busybox

COPY --from=downloader \
  /tmp/n2n/supernode \
  /tmp/n2n/edge \
  /usr/local/sbin/

COPY ./scripts/*.sh /usr/local/sbin/

CMD [ "/bin/bash" , "-c" , "/usr/local/sbin/run_n2n.sh" ]

HEALTHCHECK --interval=20s --timeout=10s CMD /usr/local/sbin/n2n_healthcheck.sh
