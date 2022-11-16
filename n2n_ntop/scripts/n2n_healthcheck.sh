#!/bin/bash

touch /n2n/environment
. /n2n/environment

check_server() {
    if busybox ping -c 1 -w 3 $SUPERNODE_HOST >/dev/null 2>&1; then
        SUPERNODE_IP=$(busybox ping -c 1 -w 3 $SUPERNODE_HOST | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -n 1)
        echo "SUPERNODE_IP 成功PING : ${SUPERNODE_IP}"
    elif nslookup $SUPERNODE_HOST 223.5.5.5 >/dev/null 2>&1; then
        SUPERNODE_IP=$(nslookup -type=a $SUPERNODE_HOST 223.5.5.5 | grep -v 223.5.5.5 | grep ddress | awk '{print $2}')
        echo "SUPERNODE_IP 成功nslookup : ${SUPERNODE_IP}"
    else
        SUPERNODE_IP=$SUPERNODE_HOST
        echo "SUPERNODE_IP : ${SUPERNODE_IP}"
    fi
}
check_edge() {
    MODE=$(echo $MODE | tr '[a-z]' '[A-Z]')
    case $MODE in
    SUPERNODE)
        check_ip=127.0.0.1
        ;;
    DHCPD)
        check_server
        check_ip=${SUPERNODE_IP}
        ;;
    DHCPC)
        # NOW_EDGE_IP=$(ifconfig $EDGE_TUN | grep "inet addr:" | awk '{print $2}' | cut -c 6-)
        NOW_EDGE_IP=$(ifconfig $EDGE_TUN | grep "inet" | awk '{print $2}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')
        if [[ -n $NOW_EDGE_IP ]]; then
            check_ip=$(echo $NOW_EDGE_IP | grep -Eo "([0-9]{1,3}[\.]){3}")1
        else
            check_server
            check_ip=${SUPERNODE_IP}
        fi
        ;;
    STATIC)
        # NOW_EDGE_IP=$(ifconfig $EDGE_TUN | grep "inet addr:" | awk '{print $2}' | cut -c 6-)
        NOW_EDGE_IP=$(ifconfig $EDGE_TUN | grep "inet" | awk '{print $2}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')
        check_ip=$(echo $NOW_EDGE_IP | grep -Eo "([0-9]{1,3}[\.]){3}")1
        ;;
    *)
        echo ${MODE} -- 判断失败
        exit 1
        ;;
    esac
}

if [[ -n "${HEALTHCHECK_IP}" ]]; then
    check_ip="${HEALTHCHECK_IP}"
else
    check_edge
    if [[ "$MODE" != "SUPERNODE" ]]; then
        cat /sys/class/net/$EDGE_TUN/address || exit 1
    fi
fi
/bin/busybox ping -c 1 -w 3 -q $check_ip || exit 1
