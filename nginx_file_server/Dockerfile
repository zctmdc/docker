FROM nginx
MAINTAINER zctmdc <zctmdc@outlook.com>

RUN set -x \
  && cat /etc/nginx/conf.d/default.conf \
  && sed -i '0,/localhost/s//_/'  /etc/nginx/conf.d/default.conf \
  && mkdir -p /var/www/static \
  && sed -i '0,/index.*/s//autoindex on;/'  /etc/nginx/conf.d/default.conf \
  && mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.example \
  && chmod a-wx /etc/nginx/conf.d/default.conf.example

COPY run.sh /usr/local/sbin/run.sh

RUN chmod a+x /usr/local/sbin/run.sh

ENV WORK_PATH="/workpath"
ENV STATIC_PATH="/var/www/static/"

EXPOSE 80

CMD ["/bin/bash", "-c", "/usr/local/sbin/run.sh"]
