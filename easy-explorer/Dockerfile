FROM alpine

MAINTAINER zctmdc <zctmdc@outlook.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN set -x \
  && apk add  --update --no-cache cifs-utils bash curl wget \
  && mkdir -p /usr/local/sbin /mnt/share/ /opt/easy_explorer\
  && echo `curl http://firmware.koolshare.cn/binary/Easy-Explorer/ \
  | grep -Eo "http://firmware.koolshare.cn/binary/Easy-Explorer/[0-9\.]+/" \
  | tail -1`easy-explorer-linux \
  | xargs wget -O /opt/easy_explorer/easy_explorer

COPY run.sh /usr/local/sbin/
COPY mount_smb.sh /usr/local/sbin/
COPY easy_explorer.sh /usr/local/sbin/

RUN set -x \
  && chmod a+x /usr/local/sbin/run.sh \
  && chmod a+x /usr/local/sbin/mount_smb.sh \
  && chmod a+x /usr/local/sbin/easy_explorer.sh \
  && chmod a+x /opt/easy_explorer/easy_explorer \
  && touch /var/log/easy_explorer.log

EXPOSE 2300
EXPOSE 8899

VOLUME /mnt/share
VOLUME /etc/easy_explorer

ENV SMB_USERNAME LZtesu_docker
ENV SMB_PASSWORD NOPASS
ENV USER_TOKEN ""

WORKDIR /opt/easy_explorer/

CMD [ "/bin/bash" , "-c" , "/usr/local/sbin/run.sh" ]
