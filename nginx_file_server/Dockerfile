FROM nginx:alpine
MAINTAINER zctmdc <zctmdc@outlook.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN set -x \
  && apk add --update --no-cache bash sed

RUN set -x \
  && cat /etc/nginx/conf.d/default.conf \
  && sed -i "0,/localhost/s//_/" /etc/nginx/conf.d/default.conf \
  && mkdir -p /var/www/static \
  && sed -i '0,/index.*/s//autoindex on;/'  /etc/nginx/conf.d/default.conf \
  && mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.example \
  && chmod 0444 /etc/nginx/conf.d/default.conf.example

COPY file_server.sh /usr/local/sbin/
COPY run.sh /usr/local/sbin/

RUN chmod a+x /usr/local/sbin/*.sh

ENV WORK_PATH /workpath

EXPOSE 80

CMD ["/bin/bash", "-c", "/usr/local/sbin/run.sh"]
