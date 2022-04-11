
FROM nginx

LABEL zctmdc <zctmdc@outlook.com>

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
# RUN sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
# RUN sed -i 's/ports.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# RUN sed -i 's/snapshot.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
# RUN sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
# RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

RUN set -x \
  && sed -i '/charset/a\    charset utf-8;' /etc/nginx/conf.d/default.conf \
  && sed -i '0,/root.*/s//root   \/tmp;/' /etc/nginx/conf.d/default.conf \
  && sed -i '0,/index.*/s//autoindex on;/'  /etc/nginx/conf.d/default.conf 

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install \
  apt-utils tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata
##################-----##################

RUN  apt-get install -y \ 
  git unzip curl ca-certificates wget sed bash

##################-----##################
RUN apt-get clean 
# RUN git config --global url."https://gitclone.com/".insteadOf https://
# RUN go env -w GOPROXY=https://goproxy.cn

COPY *.sh /usr/local/bin/

RUN chmod a+x /usr/local/bin/*.sh

RUN set -x \
  && . /usr/local/bin/init.sh \
  && qshell_version=$(curl -k -sS https://github.com/qiniu/qshell/releases/latest | grep -Eo "[vV][0-9]+.[0-9]+.[0-9]+"| head -n 1) \
  && wget --no-check-certificate -qO /tmp/qshell-${qshell_version}-${myos}-${mycpu}.tar.gz \
    http://devtools.qiniu.com/qshell-${qshell_version}-${myos}-${mycpu}.tar.gz \
  && tar -zxvf  /tmp/qshell-${qshell_version}-${myos}-${mycpu}.tar.gz -C /tmp \
  && mv /tmp/qshell /usr/local/bin/qshell

ENV WORK_PATH /tmp/

ENV FRP_TMP_DIR /tmp/frp
ENV FRP_OPT_DIR /tmp/bin

ENV N2N_TMP_DIR /tmp/n2n
ENV N2N_OPT_DIR /tmp/bin

ENV QINIUYUN_AK ""
ENV QINIUYUN_SK ""
ENV QINIUYUN_NAME ""

ENV FORCE_UPDATE FALSE

EXPOSE 80

CMD ["/bin/bash", "-c", "/usr/local/bin/run.sh"]
