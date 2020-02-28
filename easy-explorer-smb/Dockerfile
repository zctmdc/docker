FROM zctmdc/easy-explorer:Alpha

MAINTAINER zctmdc <zctmdc@outlook.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN set -x \
  && apk add --update --no-cache cifs-utils bash \
  && mkdir -p /usr/local/sbin /mnt/share/

COPY mount_smb.sh /usr/local/sbin/
COPY run.sh /usr/local/sbin/

RUN set -x \
  && chmod a+x /usr/local/sbin/run.sh \
  && chmod a+x /usr/local/sbin/mount_smb.sh

VOLUME /mnt/share

ENV SMB_USERNAME LZtesu_docker
ENV SMB_PASSWORD NOPASS

WORKDIR /mnt/share

CMD [ "/bin/bash" , "-c" , "/usr/local/sbin/run.sh" ]
