#!/bin/bash
# set -x
N2N_LOG() {
  echo $*
  logger [N2N] $*
}
N2N_LOG_RUN() {
  N2N_LOG $*
  $*
}

MODE=$(echo $MODE | tr '[a-z]' '[A-Z]')
echo MODE=$MODE

if [[ "${EDGE_ENCRYPTION:0:1}" != "-" ]]; then
  EDGE_ENCRYPTION=-$EDGE_ENCRYPTION
fi
echo EDGE_ENCRYPTION=$EDGE_ENCRYPTION

if [[ "${N2N_ARGS:0:1}" != "-" ]]; then
  N2N_ARGS=-$N2N_ARGS
fi
echo N2N_ARGS=$N2N_ARGS

init_edge_mac() {
  ignore_Iface="ztbpaislgc|docker"
  lan_eth=$(route -ne | grep 0.0.0.0 | grep -Ev "$ignore_Iface" | tail -n 1 | awk '{print $8}')
  lan_mac=$(cat /sys/class/net/$lan_eth/address)
  lan_mac_prefix=${lan_mac%:*}
  if [[ $(echo $(expr $((16#${lan_mac##*:})) - 1) | awk '{printf "%x\n",$0}') != 0 ]]; then
    lan_mac_suffix=$(echo $(expr $((16#${lan_mac##*:})) - 1) | awk '{printf "%02x\n",$0}')
  else
    lan_mac_suffix=$(echo $(expr $(echo 0x${lan_mac##*:} | awk '{printf "%d\n",$0}') - 1) | awk '{printf "%02x\n",$0}')
  fi
  edge_mac="${lan_mac_prefix}:${lan_mac_suffix}"
}

init_dhcpd_conf() {
  IP_PREFIX=$(echo $EDGE_IP | grep -Eo "([0-9]{1,3}[\.]){3}")
  if [ ! -f "/etc/dhcp/dhcpd.conf" ]; then
    mkdir -p /etc/dhcp/
    cat >"/etc/dhcp/dhcpd.conf" <<EOF
authoritative;
ddns-update-style none;
ignore client-updates;
subnet ${IP_PREFIX}0 netmask ${EDGE_NETMASK} {
  range ${IP_PREFIX}60 ${IP_PREFIX}180;
  default-lease-time 600;
  max-lease-time 7200;
}
EOF
  fi
}

mode_supernode() {
  echo $MODE -- 超级节点模式
  N2N_LOG_RUN "supernode -p $SUPERNODE_PORT $N2N_ARGS" &
}

check_edge() {
  # while [ -z $(ifconfig $EDGE_TUN | grep "inet addr:" | awk '{print $2}' | cut -c 6-) ]; do
  while [ -z $(ifconfig $EDGE_TUN | grep "inet" | awk '{print $2}') ]; do
    if [[ $MODE == "DHCP" ]]; then
      dhclient --dad-wait-time 5 $EDGE_TUN
    fi
    sleep 1
  done
}

run_edge() {
  init_edge_mac
  if [[ $EDGE_KEY ]]; then
    N2N_LOG_RUN "edge -d $EDGE_TUN -m $edge_mac -a $EDGE_IP_AGE -c $EDGE_COMMUNITY -k $EDGE_KEY -i $EDGE_REG_INTERVAL -l $SUPERNODE_IP:$SUPERNODE_PORT $EDGE_ENCRYPTION $N2N_ARGS" &
  else
    N2N_LOG_RUN "edge -d $EDGE_TUN -m $edge_mac -a $EDGE_IP_AGE -c $EDGE_COMMUNITY -i $EDGE_REG_INTERVAL -l $SUPERNODE_IP:$SUPERNODE_PORT $N2N_ARGS" &
  fi
  ifconfig $EDGE_TUN
}

mode_dhcpd() {
  touch /var/lib/dhcp/dhcpd.leases
  echo $MODE -- DHCPD 服务器模式
  init_dhcpd_conf
  # EDGE_IP=`echo $EDGE_IP | grep -Eo "([0-9]{1,3}[\.]){3}"`1
  EDGE_IP_AGE=$EDGE_IP
  run_edge
  check_edge
  echo DHCPD 服务启动中
  dhcpd -f -d $EDGE_TUN &
}

mode_dhcp() {
  echo $MODE -- DHCP客户端模式
  EDGE_IP_AGE="dhcp:0.0.0.0 -r"
  run_edge
  check_edge
}

mode_static() {
  echo $MODE -- 静态地址模式
  EDGE_IP_AGE=$EDGE_IP
  run_edge
  check_edge
}

check_server() {
  if ping -c 1 $SUPERNODE_HOST >/dev/null 2>&1; then
    SUPERNODE_IP=$(ping -c 1 $SUPERNODE_HOST | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -n 1)
    echo "成功PING SUPERNODE_IP : $SUPERNODE_IP"
  elif nslookup $SUPERNODE_HOST 223.5.5.5 >/dev/null 2>&1; then
    SUPERNODE_IP=$(nslookup -type=a $SUPERNODE_HOST 223.5.5.5 | grep -v 223.5.5.5 | grep ddress | awk '{print $2}')
    echo "成功nslookup SUPERNODE_IP : $SUPERNODE_IP"
  else
    SUPERNODE_IP=$SUPERNODE_HOST
    echo "SUPERNODE_IP : $SUPERNODE_IP"
  fi
}
restart_edge() {
  killall tail
}
#main
check_server
case $MODE in
SUPERNODE)
  mode_supernode
  ;;
DHCPD)
  mode_dhcpd
  ;;
DHCP)
  mode_dhcp
  ;;
STATIC)
  mode_static
  ;;
*)
  echo $MODE -- 判断失败
  exit 1
  ;;
esac

ifconfig

while true; do
  sleep 30
  case $MODE in
  DHCPD | DHCP | STATIC)
    last_supernode_ip=$SUPERNODE_IP
    check_server
    if [[ $last_supernode_ip != $SUPERNODE_IP ]]; then
      restart_edge
      break
    fi
    ;;
  *)
    break
    ;;
  esac
done
