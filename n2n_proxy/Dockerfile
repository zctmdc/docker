FROM zctmdc/n2n_ntop:Alpha

LABEL zctmdc <zctmdc@outlook.com>

RUN set -x \
  && gost_version=$(curl https://github.com/ginuerzh/gost/releases/latest | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+") \
  && wget -O /tmp/gost-linux-amd64-${gost_version}.gz https://github.com/ginuerzh/gost/releases/download/v${gost_version}/gost-linux-amd64-${gost_version}.gz \
  && gunzip /tmp/gost-linux-amd64-${gost_version}.gz \
  && chmod +x /tmp/gost-linux-amd64-2.11.1 \
  && mv /tmp/gost-linux-amd64-2.11.1 /bin/gost

COPY *.sh  /usr/local/sbin/

RUN set -x \
  # && apk add --update --no-cache psmisc curl \
  && chmod a+x /usr/local/sbin/*.sh

ENV EDGE_DESTINATION 192.168.0.0/16
ENV EDGE_GATEWAY ""
ENV EDGE_ROUTE FALSE
ENV EDGE_NAT FALSE
ENV EDGE_PROXY TRUE
ENV PROXY_ARGS -L=:14080
ENV PROXY_HEALTHCHECK_URL baidu.com
ENV TZ Asia/Shanghai

CMD ["/bin/bash","-c","/usr/local/sbin/run.sh"]

HEALTHCHECK --interval=20s --timeout=10s CMD /usr/local/sbin/proxy_healthcheck.sh