FROM nginx:alpine
LABEL zctmdc <zctmdc@outlook.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN set -x \
  && apk add --update --no-cache bash sed

RUN set -x \
  && sed -i '/charset/a\    charset utf-8;' /etc/nginx/conf.d/default.conf \
  && sed -i '0,/localhost/s//_/' /etc/nginx/conf.d/default.conf \
  && mkdir -p /var/www/static \
  && sed -i '0,/index.*/s//autoindex on;/'  /etc/nginx/conf.d/default.conf \
  && mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.example \
  && chmod 0444 /etc/nginx/conf.d/default.conf.example

COPY *.sh  /usr/local/sbin/

RUN chmod a+x /usr/local/sbin/*.sh

ENV WORK_PATH /workpath
ENV TZ Asia/Shanghai

EXPOSE 80

CMD ["/bin/bash", "-c", "/usr/local/sbin/run.sh"]
