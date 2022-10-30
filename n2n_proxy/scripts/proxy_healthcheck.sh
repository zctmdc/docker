if [[ $MODE == DHCP ]]; then
    # EDGE_IP=$(ifconfig $EDGE_TUN | grep "inet" | awk '{print $2}' | cut -c 6-)
    EDGE_IP=$(ifconfig $EDGE_TUN | grep "inet" | awk '{print $2}')
fi

if [[ "${EDGE_ROUTE}" == "TRUE" ]]; then
    echo 启用路由表添加
    if [ -z "${EDGE_GATEWAY}" ]; then
        EDGE_GATEWAY="$(ifconfig $EDGE_TUN | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')1"
    fi
    if [[ "$EDGE_GATEWAY" != "$EDGE_IP" ]]; then
        check_ip=$EDGE_GATEWAY
        /bin/ping -c 1 -w 5 -q $check_ip || exit 1
    fi
fi

if [[ "${EDGE_NAT}" == "TRUE" ]]; then
    echo 启用NAT
    /usr/local/sbin/n2n_healthcheck.sh || exit 1
fi

if [[ "${EDGE_PROXY}" == "TRUE" ]]; then
    echo 启用代理
    proxy_port=$(echo $PROXY_ARGS | grep -Eo "L=[a-zA-Z0-9:@/]*?:[0-9]+" | grep -Eo "[0-9]+$")
    curl -k -x localhost:$proxy_port $PROXY_HEALTHCHECK_URL || exit 1
fi

/usr/local/sbin/n2n_healthcheck.sh || exit 1
