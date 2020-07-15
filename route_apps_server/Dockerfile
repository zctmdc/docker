FROM zctmdc/file-server:Alpha
MAINTAINER zctmdc <zctmdc@outlook.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN set -x \
  && apk add --update --no-cache unzip curl git sed bash \
  && mkdir -p /usr/local/sbin/
run wget -O /tmp/qshell-linux-x64-v2.4.2.zip http://devtools.qiniu.com/qshell-linux-x64-v2.4.2.zip \
  && unzip -u /tmp/qshell-linux-x64-v2.4.2.zip -d /tmp \
  && mv /tmp/qshell-linux-x64-v2.4.2 /usr/local/sbin/
COPY frp_download.sh /usr/local/sbin/
COPY n2n_download.sh /usr/local/sbin/
COPY run.sh /usr/local/sbin/

RUN chmod a+x /usr/local/sbin/*.sh

EXPOSE 80

ENV FRP_TMP_DIR /tmp/frp
ENV FRP_OPT_DIR /tmp/bin
ENV WORK_PATH /tmp/
ENV N2N_TMP_DIR /tmp/n2n
ENV N2N_OPT_DIR /tmp/bin
ENV WORK_PATH /tmp
ENV TZ Asia/Shanghai
ENV QINIUYUN_AK ""
ENV QINIUYUN_SK ""
ENV QINIUYUN_NAME ""

ENV FORCE_UPDATE FALSE

CMD ["/bin/bash", "-c", "/usr/local/sbin/run.sh"]
