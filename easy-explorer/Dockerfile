FROM alpine as downloader

LABEL zctmdc <zctmdc@outlook.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --update --no-cache tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del tzdata

RUN buildDeps=" \
  curl \
  wget \
  "; \
  \
  set -x \
  && apk add --update --no-cache --virtual .build-deps $buildDeps

RUN set -x \
  && echo `curl http://firmware.koolshare.cn/binary/Easy-Explorer/ \
  | grep -Eo "http://firmware.koolshare.cn/binary/Easy-Explorer/[0-9\.]+/" \
  | tail -1`easy-explorer-linux \
  | xargs wget -O /tmp/easy-explorer

FROM alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN mkdir -p /usr/local/sbin /etc/easy-explorer /opt/easy-explorer /mnt/share/
COPY --from=downloader /tmp/easy-explorer /usr/local/sbin/
COPY run.sh /usr/local/sbin/
COPY easy-explorer.sh /usr/local/sbin/

RUN set -x \
  && apk add --update --no-cache bash

RUN set -x \
  && chmod a+x /usr/local/sbin/*.sh \
  && chmod a+x /usr/local/sbin/easy-explorer \
  && touch /var/log/easy-explorer.log

EXPOSE 2300
EXPOSE 8899

VOLUME /mnt/share

ENV USER_TOKEN ""
ENV TZ Asia/Shanghai

WORKDIR /opt/easy-explorer/

CMD [ "/bin/bash" , "-c" , "/usr/local/sbin/run.sh" ]
