
FROM golang:alpine

LABEL zctmdc <zctmdc@outlook.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --update --no-cache tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del tzdata

RUN  apk add --update --no-cache make git unzip curl wget sed bash # tsocks

# RUN echo -e "local = 192.168.0.0/255.255.0.0\nserver = 192.168.1.92\nserver_type = 5\nserver_port = 10808" >"/etc/tsocks.conf"

RUN go env -w GOPROXY=https://goproxy.cn 
RUN git config --global url."https://gitclone.com/".insteadOf https://

COPY *.sh /usr/local/bin/
COPY *.go /usr/local/bin/

RUN chmod a+x /usr/local/bin/*.sh

RUN set -x \
&& . /usr/local/bin/init.sh \
&&  qshell_version=$(curl https://github.com/qiniu/qshell/releases/latest | grep -Eo "[vV][0-9]+.[0-9]+.[0-9]+") \
&& wget -O /tmp/qshell-${qshell_version}-${myos}-${mycpu}.tar.gz http://devtools.qiniu.com/qshell-${qshell_version}-${myos}-${mycpu}.tar.gz \
  && tar -zxvf  /tmp/qshell-${qshell_version}-${myos}-${mycpu}.tar.gz -C /tmp \
  && mv /tmp/qshell /usr/local/bin/qshell

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
