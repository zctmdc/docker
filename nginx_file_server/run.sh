#!/bin/bash
set -x
if [ -d $WORK_PATH ]; then
    echo "$WORK_PATH 是目录"
    sed '0,/\/usr\/share\/nginx\/html;/s//\/workpath;/'  /etc/nginx/conf.d/default.conf.example > /etc/nginx/conf.d/default.conf
    cat  /etc/nginx/conf.d/default.conf
elif [ -f $WORK_PATH ] ;then
    echo  "$WORK_PATH 是文件"
    mount -o loop $WORK_PATH $STATIC_PATH
    sed -i '0,/\/usr\/share\/nginx\/html;/s//\/var\/www\/static;/'  /etc/nginx/conf.d/default.conf.example > /etc/nginx/conf.d/default.conf
else
    echo  "$WORK_PATH 不存在"
fi
nginx -g "daemon off;"
