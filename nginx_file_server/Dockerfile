FROM nginx
MAINTAINER zctmdc <zctmdc@outlook.com>

RUN set -x \
  && cat /etc/nginx/conf.d/default.conf \
  && sed -i '0,/localhost/s//_/'  /etc/nginx/conf.d/default.conf \
  && mkdir -p /var/www/static \
  && sed -i '0,/\/usr\/share\/nginx\/html;/s//\/var\/www\/static;/'  /etc/nginx/conf.d/default.conf \
  && sed -i '0,/index.*/s//autoindex on;/'  /etc/nginx/conf.d/default.conf \
  && cat /etc/nginx/conf.d/default.conf

ENV WORK_PATH="/workpath"
ENV STATIC_PATH="/var/www/static/"

COPY run.sh /usr/sbin/run.sh
RUN chmod a+x /usr/sbin/run.sh
CMD ["/bin/bash","-c","/usr/sbin/run.sh"]