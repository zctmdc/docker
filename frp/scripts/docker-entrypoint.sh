#!/bin/bash

MODE=${1:-$MODE}

if [ "$MODE^^" = "RUN_FRPC" ];then

    /usr/bin/frpc -c /etc/frp/frpc.ini
elif [ "$MODE^^" = "RUN_FRPS" ];then
    /usr/bin/frps -c /etc/frp/frps.ini
fi

exec "$@"
