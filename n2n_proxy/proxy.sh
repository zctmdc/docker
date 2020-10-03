#!/bin/bash
# set -x

if [[ "${EDGE_ROUTE}" == "TRUE" ]]; then
  echo 启用路由表添加
  if [ -z "${EDGE_GATEWAY}" ]; then
    EDGE_GATEWAY="$(ifconfig $EDGE_TUN | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')1"
  fi
  if [[ "$EDGE_GATEWAY" != "$EDGE_IP" ]]; then
    route add -net $EDGE_DESTINATION gw $EDGE_GATEWAY
    wan_eth="$(ifconfig | grep eth | awk '{print $1}')"
    wan_gateway=$(ifconfig $wan_eth | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')1
    wan_subnet=$(ifconfig $wan_eth | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')0/24
    route add -net $wan_subnet gw $wan_gateway
  fi
fi
if [[ "${EDGE_NAT}" == "TRUE" ]]; then
  echo 启用NAT
  lan_eth=$EDGE_TUN
  wan_eth="$(ifconfig | grep eth | awk '{print $1}')"
  lan_ip=$(ifconfig $lan_eth | grep "inet addr:" | awk '{print $2}' | cut -c 6-)
  lan_gateway=$(ifconfig $lan_eth | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')1
  lan_subnet=$(ifconfig $lan_eth | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')0/24
  wan_ip=$(ifconfig $wan_eth | grep "inet addr:" | awk '{print $2}' | cut -c 6-)
  wan_gateway=$(ifconfig $wan_eth | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')1
  wan_subnet=$(ifconfig $wan_eth | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')0/24

  sysctl net.ipv4.ip_forward=1
  iptables -A INPUT -i $lan_eth -j ACCEPT
  iptables -A FORWARD -i $wan_eth -j ACCEPT
  iptables -t nat -A POSTROUTING -s $lan_subnet -o $wan_eth -j MASQUERADE
fi
route -n
if [[ "${EDGE_PROXY}" == "TRUE" ]]; then
  echo ${EDGE_PROXY} -- 启用代理
  /bin/gost $PROXY_ARGS &
fi
