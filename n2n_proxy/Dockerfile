FROM zctmdc/n2n_ntop:Alpha

LABEL zctmdc <zctmdc@outlook.com>

COPY ./scripts/*.sh /usr/local/sbin/

RUN chmod a+x /usr/local/sbin/*

ENV EDGE_DESTINATION 192.168.0.0/16
ENV EDGE_GATEWAY ""
ENV EDGE_ROUTE FALSE
ENV EDGE_NAT FALSE
ENV PROXY_HEALTHCHECK_URL baidu.com
ENV TZ Asia/Shanghai

CMD ["/bin/bash","-c","/usr/local/sbin/run.sh"]

HEALTHCHECK --interval=20s --timeout=10s CMD /usr/local/sbin/proxy_healthcheck.sh
