FROM golang:alpine as buildDeps

RUN set -x \
  && apk add --update --no-cache git make

RUN git clone https://github.com/fatedier/frp.git /tmp/frp/ 

WORKDIR /tmp/frp

RUN make \
  && echo "frp version: `/tmp/frp/bin/frps --version`"

FROM alpine

LABEL zctmdc <zctmdc@outlook.com>

RUN apk add --update --no-cache tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del tzdata

RUN apk add --update --no-cache bash curl  
# wget 

RUN  mkdir -p /etc/frp

COPY --from=buildDeps /tmp/frp/bin/frps  /usr/sbin/frps
COPY --from=buildDeps /tmp/frp/bin/frpc  /usr/sbin/frpc

COPY ./frpc.ini /etc/frp/
COPY ./frps.ini /etc/frp/

CMD ["echo" ,"-e", "'RUN FRPS\n  /usr/sbin/frps -c /etc/frp/frps.ini\nRUN FRPC\n  /usr/sbin/frpc -c /etc/frp/frpc.ini'"]

# CMD ["/usr/sbin/frps", "-c", "/etc/frp/frps.ini"]
# CMD ["/usr/sbin/frpc", "-c", "/etc/frp/frpc.ini"]

