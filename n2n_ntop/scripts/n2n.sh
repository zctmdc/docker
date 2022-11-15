#!/bin/bash

# set -x
. init_logger.sh

MODE=$(echo $MODE | tr '[a-z]' '[A-Z]')
LOG_INFO "MODE=${MODE}"

if [[ -n "${EDGE_ENCRYPTION}" && "${EDGE_ENCRYPTION:0:1}" != "-" ]]; then
  EDGE_ENCRYPTION="-${EDGE_ENCRYPTION}"
fi
LOG_INFO "EDGE_ENCRYPTION=${EDGE_ENCRYPTION}"

if [[ -n "${N2N_ARGS}" && "${N2N_ARGS:0:1}" != "-" ]]; then
  N2N_ARGS="-$N2N_ARGS"
fi
LOG_INFO "N2N_ARGS=$N2N_ARGS"
init_version() {
  small_version="$(edge -h | grep Welcome | grep -Eo 'v\.[0-9]\.[0-9]\.[0-9]' | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
  if [[ -n "${small_version}" ]]; then
    return
  fi
  version_b_s_rc=${VERSION_B_S_rC}
  if [[ -z "${version_b_s_rc}" ]]; then
    LOG_ERROR "错误: SCAN_ONE_BUILD - version_b_s_rc - 为空"
    return
  fi
  small_version="$(echo ${version_b_s_rc} | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
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
  LOG_INFO $MODE -- 超级节点模式
  init_version
  if [[ -n "${small_version}" && "${small_version//./}" -ge 290 ]]; then
    # 3.9.0+  使用 -p
    ARG_SUPERNODE_PORT="-p $SUPERNODE_PORT"
  else
    ARG_SUPERNODE_PORT="-l $SUPERNODE_PORT"
  fi
  LOG_RUN "supernode ${ARG_SUPERNODE_PORT} $N2N_ARGS" &
}

check_edge() {
  while true; do
    if [[ ! -f /sys/class/net/$EDGE_TUN/address ]]; then
      LOG_WARNING "等待启动: $EDGE_TUN"
      continue
    fi
    if [[ $MODE == "DHCP" ]]; then
      LOG_RUN dhclient -d --dad-wait-time 5 $EDGE_TUN &
      sleep 3
    fi
    if [[ -z $(ifconfig $EDGE_TUN | grep "inet" | awk '{print $2}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}') ]]; then
      LOG_RUN dhclient -x
    fi
    sleep 1
  done
}

run_edge() {
  # init_edge_mac_address
  LOG_RUN "edge -d $EDGE_TUN ${EDGE_MAC:+ -m ${EDGE_MAC}} -a $EDGE_IP_AGE -c $EDGE_COMMUNITY -l $SUPERNODE_IP:$SUPERNODE_PORT ${EDGE_KEY:+ -k ${EDGE_KEY} $EDGE_ENCRYPTION} $N2N_ARGS" &
  ifconfig $EDGE_TUN
}

mode_dhcpd() {
  touch /var/lib/dhcp/dhcpd.leases
  LOG_INFO $MODE -- DHCPD 服务器模式
  init_dhcpd_conf
  # EDGE_IP=`echo $EDGE_IP | grep -Eo "([0-9]{1,3}[\.]){3}"`1
  EDGE_IP_AGE=$EDGE_IP
  run_edge
  check_edge
  LOG_INFO DHCPD 服务启动中
  dhcpd -f -d $EDGE_TUN &
}

mode_dhcp() {
  LOG_INFO $MODE -- DHCP客户端模式
  EDGE_IP_AGE="dhcp:0.0.0.0 -r"
  run_edge
  check_edge
}

mode_static() {
  LOG_INFO $MODE -- 静态地址模式
  EDGE_IP_AGE=$EDGE_IP
  run_edge
  check_edge
}

check_server() {
  if ping -c 1 $SUPERNODE_HOST >/dev/null 2>&1; then
    SUPERNODE_IP=$(busybox ping -c 1 $SUPERNODE_HOST | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
    LOG_INFO "成功PING SUPERNODE_IP : $SUPERNODE_IP"
  elif nslookup $SUPERNODE_HOST 223.5.5.5 >/dev/null 2>&1; then
    SUPERNODE_IP=$(busybox nslookup -type=a $SUPERNODE_HOST 223.5.5.5 | grep -v 223.5.5.5 | grep ddress | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
    LOG_INFO "成功nslookup SUPERNODE_IP : $SUPERNODE_IP"
  else
    SUPERNODE_IP=$SUPERNODE_HOST
    LOG_INFO "SUPERNODE_IP : $SUPERNODE_IP"
  fi
}
restart_edge() {
  busybox killall edge
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
  LOG_ERROR "$MODE -- 判断失败"
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
    continue
    ;;
  esac
done
