
FROM hkjn/fileserver

LABEL zctmdc <zctmdc@outlook.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN set -x \
  && apk add --update --no-cache make git unzip curl wget sed bash tsocks

RUN echo -e "local = 192.168.0.0/255.255.0.0\nserver = 192.168.1.92\nserver_type = 5\nserver_port = 10808" >"/etc/tsocks.conf"

RUN  go env -w GOPROXY=https://goproxy.cn 

COPY *.sh /usr/local/bin/
COPY *.go /usr/local/bin/

RUN chmod a+x /usr/local/bin/*.sh

RUN wget -O /tmp/qshell-linux-x64-v2.4.2.zip http://devtools.qiniu.com/qshell-linux-x64-v2.4.2.zip \
  && unzip -o  -d /tmp /tmp/qshell-linux-x64-v2.4.2.zip \
  && chmod +x /tmp/qshell-linux-x64-v2.4.2 \
  && mv /tmp/qshell-linux-x64-v2.4.2 /usr/local/bin/qshell

EXPOSE 80

ENV WORK_PATH /tmp/
ENV FRP_TMP_DIR /tmp/frp
ENV FRP_OPT_DIR /tmp/bin
ENV N2N_TMP_DIR /tmp/n2n
ENV N2N_OPT_DIR /tmp/bin
ENV TZ Asia/Shanghai
ENV QINIUYUN_AK ""
ENV QINIUYUN_SK ""
ENV QINIUYUN_NAME ""

ENV FORCE_UPDATE FALSE

CMD ["/bin/bash", "-c", "/usr/local/bin/run.sh"]
