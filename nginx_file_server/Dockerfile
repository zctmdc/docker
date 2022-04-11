FROM nginx

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -yqq upgrade
RUN apt-get -yqq install \
  apt-utils tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata
##################-----##################


##################-----##################
RUN apt-get clean 

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

HEALTHCHECK --interval=20s --timeout=3s CMD curl "localhost:80" || exit 1