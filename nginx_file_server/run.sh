#!/bin/bash
if [ -d $WORK_PATH ]
then
    echo "$WORK_PATH 是目录"
    sed -i '0,/\/var\/www\/static/s//\/workpath/'  /etc/nginx/conf.d/default.conf
    cat   /etc/nginx/conf.d/default.conf
    # ln –s $WORK_PATH $STATIC_PATH
elif [ -f $WORK_PATH ]
then
    echo  "$WORK_PATH 是文件"
    mount -o loop $WORK_PATH $STATIC_PATH
else
    echo  "$WORK_PATH 不存在"
fi

nginx -g "daemon off;"