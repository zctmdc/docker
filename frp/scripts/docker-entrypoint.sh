#!/bin/sh

MODE=${1:-$MODE}

if [ "$(echo ${MODE} | tr 'a-z' 'A-Z')" = "RUN_FRPC" ]; then
    exec /usr/bin/frpc -c /etc/frp/frpc.ini
elif [ "$(echo ${MODE} | tr 'a-z' 'A-Z')" = "RUN_FRPS" ]; then
    exec /usr/bin/frps -c /etc/frp/frps.ini
fi

exec $*
