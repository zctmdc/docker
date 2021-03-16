#!/bin/bash
# set -x

EDGE_ROUTE=$(echo $EDGE_ROUTE | tr '[a-z]' '[A-Z]')
echo EDGE_ROUTE=$EDGE_ROUTE

EDGE_NAT=$(echo $EDGE_NAT | tr '[a-z]' '[A-Z]')
echo EDGE_NAT=$EDGE_NAT

EDGE_PROXY=$(echo $EDGE_PROXY | tr '[a-z]' '[A-Z]')
echo EDGE_PROXY=$EDGE_PROXY

if [[ "${EDGE_ROUTE}" == "TRUE" ]]; then
  echo 启用路由表添加
  if [ -z "${edge_gateway}" ]; then
    # edge_gateway="$(ifconfig $EDGE_TUN | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')1"
    edge_gateway=$(ifconfig $EDGE_TUN | grep inet | awk '{print $2}' | grep -Eo "([0-9]{1,3}.){3}")1
  fi

  if [[ $MODE == DHCP ]]; then
    # edge_ip=$(ifconfig $EDGE_TUN | grep "inet addr:" | awk '{print $2}' | cut -c 6-)
    edge_ip=$(ifconfig $EDGE_TUN | grep "inet" | awk '{print $2}')
  fi

  if [[ "$edge_gateway" != "$edge_ip" ]]; then

    # lan_eth="$(ifconfig | awk '{print $1}' | grep eth )"
    # lan_prefix=$(ifconfig $lan_eth | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')
    # lan_gateway=${lan_prefix}1
    # lan_subnet=${lan_prefix}0/24

    # lan_eth="$(ifconfig | grep -Eo '^eth[0-9a-zA-Z]*')"
    # lan_prefix=$(ifconfig $lan_eth | grep inet | awk '{print $2}' | grep -Eo "([0-9]{1,3}.){3}")
    # lan_gateway=${lan_prefix}1
    # lan_subnet=${lan_prefix}0/24

    # lan_eth=$(route -ne | grep -Eo "^0.0.0.0.*" | awk '{print $8}')
    # lan_prefix=$(route -ne | grep -Eo "^0.0.0.0.*" | awk '{print $2}' | tail -n 1 | grep -Eo "([0-9]{1,3}.){3}")
    # lan_gateway=${lan_prefix}1
    # lan_subnet=${lan_prefix}0/24

    lan_eth=$(route -ne | grep 0.0.0.0 | tail -n 1 | awk '{print $8}')
    lan_prefix=$(route -ne | grep 0.0.0.0 | tail -n 1 | awk '{print $1}' | grep -Eo "([0-9]{1,3}.){3}")
    lan_ip=$(ifconfig $lan_eth | grep inet | grep -Eo "${lan_prefix}[0-9]{1,3}" | grep -v ${lan_prefix}255)
    lan_gateway=${lan_prefix}1
    lan_subnet=${lan_prefix}0/24
    if traceroute -4 -I -n -m 1 119.29.29.29 >/dev/null 2>&1; then
      route_ip=$(traceroute -4 -I -n -m 4 119.29.29.29 | grep 192.168. | awk '{print $2}' | head -n 1)
    else
      route_ip=$(traceroute -I -m 4 119.29.29.29 | grep 192.168. | awk '{print $2}' | head -n 1)
    fi
    if [[ $EDGE_DESTINATION != $lan_subnet ]]; then
      route add -net $EDGE_DESTINATION gw $edge_gateway
    fi
    if [[ $route_ip && $route_ip != $lan_gateway ]]; then
      echo "获取路由地址 - $route_ip"
      route_ip_subnet=$(echo $route_ip | grep -Eo "([0-9]{1,3}.){3}")0/24
      route add -net $route_ip_subnet gw $lan_gateway
    fi

    # route add -net $lan_subnet gw $lan_gateway
  fi
fi
if [[ "${EDGE_NAT}" == "TRUE" ]]; then
  echo 启用NAT
  # lan_eth=$EDGE_TUN
  # lan_eth="$(ifconfig | grep eth | awk '{print $1}')"
  # edge_ip=$(ifconfig $lan_eth | grep "inet addr:" | awk '{print $2}' | cut -c 6-)
  # edge_prefix=$(ifconfig $lan_eth | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')
  # edge_gateway=${edge_prefix}1
  # edge_subnet=${edge_prefix}0/24

  # lan_ip=$(ifconfig $lan_eth | grep "inet addr:" | awk '{print $2}' | cut -c 6-)
  # lan_prefix=$(ifconfig $lan_eth | sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p')
  # lan_gateway=${lan_prefix}1
  # lan_subnet=${lan_prefix}0/24

  edge_ip=$(ifconfig $EDGE_TUN | grep "inet" | awk '{print $2}' | grep -Eo "([0-9]{1,3}.){3}[0-9]{1,3}" | tail -n 1)
  edge_prefix=$(ifconfig $EDGE_TUN | grep inet | awk '{print $2}' | grep -Eo "([0-9]{1,3}.){3}")
  edge_gateway=${edge_prefix}1
  edge_subnet=${edge_prefix}0/24

  lan_eth=$(route -ne | grep 0.0.0.0 | tail -n 1 | awk '{print $8}')
  lan_prefix=$(route -ne | grep 0.0.0.0 | tail -n 1 | awk '{print $1}' | grep -Eo "([0-9]{1,3}.){3}")
  lan_gateway=${lan_prefix}1
  lan_subnet=${lan_prefix}0/24

  sed -i 's/.*et\.ipv4\.ip_forward.*/net\.ipv4\.ip_forward = 1/' /etc/sysctl.conf
  sysctl -p

  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT

  iptables -A INPUT -i $EDGE_TUN -j ACCEPT
  iptables -A FORWARD -i $EDGE_TUN -j ACCEPT

  iptables -A INPUT -i $lan_eth -j ACCEPT
  iptables -A FORWARD -i $lan_eth -j ACCEPT

  # iptables -t nat -A POSTROUTING -s $edge_subnet -j MASQUERADE
  # iptables -t nat -A POSTROUTING -s $lan_subnet -o $EDGE_TUN -j MASQUERADE

  iptables -t nat -A POSTROUTING -o $EDGE_TUN -j MASQUERADE
  iptables -t nat -A POSTROUTING -o $lan_eth -j MASQUERADE
  
  # iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to-destination $lan_eth:22
  route -n
fi

if [[ "${EDGE_PROXY}" == "TRUE" ]]; then
  echo 启用代理
  /usr/local/bin/gost $PROXY_ARGS &
fi
