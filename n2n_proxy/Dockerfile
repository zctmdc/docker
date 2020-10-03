FROM ginuerzh/gost as gost_src
FROM zctmdc/n2n_ntop:Alpha

LABEL zctmdc <zctmdc@outlook.com>

COPY --from=gost_src /bin/gost /bin/
COPY *.sh  /usr/local/sbin/

RUN set -x \
  && apk add --update --no-cache psmisc \
  && chmod a+x /usr/local/sbin/*.sh

ENV EDGE_DESTINATION 192.168.0.0/16
ENV EDGE_GATEWAY ""
ENV EDGE_ROUTE FALSE
ENV EDGE_NAT FALSE
ENV EDGE_PROXY TRUE
ENV PROXY_ARGS -L=:14080
ENV TZ Asia/Shanghai

CMD ["/bin/bash","-c","/usr/local/sbin/run.sh"]
