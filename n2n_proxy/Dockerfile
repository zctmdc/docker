FROM golang as builder 
WORKDIR /tmp
RUN go env -w GOPROXY=https://goproxy.cn \
  && git config --global url."https://gitclone.com/".insteadOf https:// \
  && git clone https://github.com/ginuerzh/gost.git \
  && cd gost/cmd/gost \
  && go build \
  && chmod +x gost 

FROM zctmdc/n2n_ntop:Alpha

LABEL zctmdc <zctmdc@outlook.com>

COPY *.sh  /usr/local/sbin/
RUN chmod a+x /usr/local/sbin/*
# RUN set -x \
#   && chmod a+x /usr/local/sbin/*.sh \
#   && . /usr/local/sbin/init.sh \
#   && gost_version=$(curl https://github.com/ginuerzh/gost/releases/latest | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+") \
#   && wget -O /tmp/gost-${myos}-${mycpu}-${gost_version}.gz https://github.com/ginuerzh/gost/releases/download/v${gost_version}/gost-${myos}-${mycpu}-${gost_version}.gz \
#   && gunzip -f /tmp/gost-${myos}-${mycpu}-${gost_version}.gz \
#   && chmod +x /tmp/gost-${myos}-${mycpu}-${gost_version} \
#   && cp -f /tmp/gost-${myos}-${mycpu}-${gost_version} /usr/local/bin/gost

COPY --from=builder /tmp/gost/cmd/gost/gost /usr/local/bin/gost 


RUN set -x \
  # && apk add --update --no-cache psmisc curl \
  && chmod a+x /usr/local/sbin/*

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