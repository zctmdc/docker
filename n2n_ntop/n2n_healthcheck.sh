check_server() {
    if ping -c 1 $SUPERNODE_HOST >/dev/null 2>&1; then
        SUPERNODE_IP=$(ping -c 1 $SUPERNODE_HOST | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -n 1)
        echo "SUPERNODE_IP 成功PING : ${SUPERNODE_IP}"
    elif nslookup $SUPERNODE_HOST 223.5.5.5 >/dev/null 2>&1; then
        SUPERNODE_IP=$(nslookup -type=a $SUPERNODE_HOST 223.5.5.5 | grep -v 223.5.5.5 | grep ddress | awk '{print $2}')
        echo "SUPERNODE_IP 成功nslookup : ${SUPERNODE_IP}"
    else
        SUPERNODE_IP=$SUPERNODE_HOST
        echo "SUPERNODE_IP : ${SUPERNODE_IP}"
    fi
}

case $MODE in
SUPERNODE)
    check_uri=127.0.0.1
    ;;
DHCPD)
    check_server
    check_uri=${SUPERNODE_IP}
    ;;
DHCP)
    NOW_EDGE_IP=$(ifconfig $EDGE_TUN | grep "inet addr:" | awk '{print $2}' | cut -c 6-)
    if [[ -n $NOW_EDGE_IP ]]; then
        check_uri=$(echo $NOW_EDGE_IP | grep -Eo "([0-9]{1,3}[\.]){3}")1
    else
        check_server
        check_uri=${SUPERNODE_IP}
    fi
    ;;
STATIC)
    NOW_EDGE_IP=$(ifconfig $EDGE_TUN | grep "inet addr:" | awk '{print $2}' | cut -c 6-)
    check_uri=$(echo $NOW_EDGE_IP | grep -Eo "([0-9]{1,3}[\.]){3}")1
    ;;
*)
    echo ${MODE} -- 判断失败
    exit 1
    ;;
esac

/bin/ping -c 1 -w 5 -q $check_uri || exit 1
