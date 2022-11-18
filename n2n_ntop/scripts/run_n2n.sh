#!/bin/bash

# set -x
. init_logger.sh
. init_version.sh

MODE=$(echo "${MODE}" | tr '[a-z]' '[A-Z]')
LOG_INFO "MODE=${MODE}"

if [[ -n "${EDGE_ENCRYPTION}" && "${EDGE_ENCRYPTION:0:1}" != "-" ]]; then
  EDGE_ENCRYPTION="-${EDGE_ENCRYPTION}"
fi
LOG_INFO "EDGE_ENCRYPTION=${EDGE_ENCRYPTION}"

if [[ "${USE_DEFALT_ARG^^}" == "TRUE" ]]; then
  LOG_INFO "USE_DEFALT_ARG=${USE_DEFALT_ARG}"

  if [[ "${MODE}" == "SUPERNODE" ]]; then
    case "${VERSION_B_S_rC%%_*}" in
    "v1")
      N2N_ARGS="${N2N_ARGS}"
      ;;
    "v2")
      N2N_ARGS="${N2N_ARGS}  -f"
      ;;
    "v2s")
      N2N_ARGS="${N2N_ARGS}  -f"
      ;;
    "v3")
      N2N_ARGS="${N2N_ARGS}  -f -F ${EDGE_TUN}"
      ;;
    esac
  elif [[ "$(echo ${MODE} | grep -E '^(DHCPD)|(DHCPC)|(STATIC)$')" ]]; then
    case "${VERSION_B_S_rC%%_*}" in
    "v1")
      N2N_ARGS="${N2N_ARGS} -br"
      ;;
    "v2")
      N2N_ARGS="${N2N_ARGS} -EfrA"
      ;;
    "v2s")
      N2N_ARGS="${N2N_ARGS} -bfr -L auto"
      ;;
    "v3")
      N2N_ARGS="${N2N_ARGS} -Efr -e auto -I ${EDGE_TUN}"
      ;;
    esac
  fi
fi
N2N_ARGS="$(echo ${N2N_ARGS})"
if [[ -n "${N2N_ARGS}" && "${N2N_ARGS:0:1}" != "-" ]]; then
  N2N_ARGS="-${N2N_ARGS}"
fi
LOG_INFO "N2N_ARGS=${N2N_ARGS}"

init_dhcpd_conf() {
  touch /var/lib/dhcp/dhcpd.leases
  IP_PREFIX=$(echo "${EDGE_IP}" | grep -Eo "([0-9]{1,3}[\.]){3}")
  mkdir -p /etc/dhcp/
  if [ -f "/n2n/conf/dhcpd.conf" ]; then
    cp /n2n/conf/dhcpd.conf /etc/dhcp/dhcpd.conf
  elif [ -f "/n2n/conf/udhcpd.conf" ]; then
    cp /n2n/conf/udhcpd.conf /etc/dhcp/udhcpd.conf
    echo "interface ${EDGE_TUN}" >>/etc/dhcp/udhcpd.conf
  else
    cat >"/etc/dhcp/dhcpd.conf" <<EOF
authoritative;
ddns-update-style none;
ignore client-updates;
subnet ${IP_PREFIX}0 netmask ${EDGE_NETMASK} {
  range ${IP_PREFIX}120 ${IP_PREFIX}240;
  default-lease-time 600;
  max-lease-time 7200;
}
EOF
  fi
}

mode_supernode() {
  LOG_INFO $MODE -- 超级节点模式
  INIT_VERSION
  if [[ -n "${small_version}" && "${small_version//./}" -ge 290 ]]; then
    # v.2.9.0+  使用 -p
    ARG_SUPERNODE_PORT="-p ${SUPERNODE_PORT}"
  else
    ARG_SUPERNODE_PORT="-l ${SUPERNODE_PORT}"
  fi
  LOG_RUN "supernode ${ARG_SUPERNODE_PORT} $N2N_ARGS" &
}

check_edge() {
  while true; do
    if [[ ! -f /sys/class/net/${EDGE_TUN}/address ]]; then
      LOG_WARNING "等待启动: ${EDGE_TUN}"
      sleep 1
      continue
    fi
    if [[ "${MODE}" == "DHCPC" ]]; then
      LOG_RUN dhclient -x
      LOG_RUN dhclient -d --dad-wait-time 5 ${EDGE_TUN} &
      sleep 10
    fi
    if [[ -z "$(ifconfig ${EDGE_TUN} | grep "inet" | awk '{print $2}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')" ]]; then
      LOG_WARNING "未获得IP: ${EDGE_TUN}"
      continue
    fi
    LOG_INFO "启动完毕: ${EDGE_TUN} \n\n$(ifconfig ${EDGE_TUN})"
    break
  done
}
check_mac_address() {
  if [[ "${GET_MAC_FROM_WAN^^}" == 'TRUE' ]]; then
    . init_edge_mac_from_wan.sh
    INIT_EDGE_MAC_FROM_WAN
  fi
  if [[ -n "${EDGE_MAC}" ]]; then
    # 判断 $EDGE_MAC 是否为有效MAC地址
    if [[ "${EDGE_MAC}" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
      EDGE_MAC=$(echo $EDGE_MAC | tr '[a-z]' '[A-Z]')
    else
      EDGE_MAC=""
      return
    fi
    return
  fi
}
run_edge() {
  # init_edge_mac_address
  LOG_RUN "edge -d ${EDGE_TUN} ${EDGE_MAC:+ -m ${EDGE_MAC}} -a ${EDGE_IP_AGE} -c ${EDGE_COMMUNITY} -l ${SUPERNODE_IP}:${SUPERNODE_PORT} ${EDGE_KEY:+ -k ${EDGE_KEY} ${EDGE_ENCRYPTION}} ${N2N_ARGS}" &
}

mode_dhcpd() {

  LOG_INFO "${MODE} -- DHCPD 服务器模式"
  init_dhcpd_conf
  # EDGE_IP=`echo $EDGE_IP | grep -Eo "([0-9]{1,3}[\.]){3}"`1
  EDGE_IP_AGE="${EDGE_IP}"
  check_mac_address
  run_edge
  check_edge

  LOG_INFO 'DHCPD 服务启动中'
  if [ -f "/etc/dhcp/dhcpd.conf" ]; then
    dhcpd -f -d "${EDGE_TUN}" &
  elif [ -f "/etc/dhcp/udhcpd.conf" ]; then
    busybox udhcpd -f /etc/dhcp/udhcpd.conf
  fi
}

mode_dhcpc() {
  LOG_INFO "${MODE} -- DHCPC客户端模式"
  EDGE_IP_AGE="dhcp:0.0.0.0 -r"
  check_mac_address
  run_edge
  check_edge
}

mode_static() {
  LOG_INFO "${MODE} -- 静态地址模式"
  EDGE_IP_AGE="${EDGE_IP}"
  check_mac_address
  run_edge
  check_edge
}

check_server() {
  if busybox ping -c 1 -w 3 ${SUPERNODE_HOST} >/dev/null 2>&1; then
    SUPERNODE_IP=$(busybox ping -c 1 -w 3 ${SUPERNODE_HOST} | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
    LOG_INFO "成功PING SUPERNODE_IP : ${SUPERNODE_IP}"
  elif nslookup ${SUPERNODE_HOST} 223.5.5.5 >/dev/null 2>&1; then
    SUPERNODE_IP=$(busybox nslookup -type=a ${SUPERNODE_HOST} 223.5.5.5 | grep -v 223.5.5.5 | grep ddress | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
    LOG_INFO "成功nslookup SUPERNODE_IP : ${SUPERNODE_IP}"
  else
    SUPERNODE_IP=${SUPERNODE_HOST}
    LOG_WARNING "SUPERNODE_IP : ${SUPERNODE_IP}"
  fi
}

main() {
  check_server
  case ${MODE} in
  SUPERNODE)
    mode_supernode
    ;;
  DHCPD)
    mode_dhcpd
    ;;
  DHCPC)
    mode_dhcpc
    ;;
  STATIC)
    mode_static
    ;;
  *)
    LOG_ERROR "MODE: ${MODE} -- 判断失败"
    exit 1
    ;;
  esac
}
restart_edge() {
  LOG_RUN dhclient -x
  busybox killall edge
  main
}
check_run() {
  LOG_INFO "启动程序执行完毕，守护程序启动。"
  while true; do
    sleep 15
    case ${MODE} in
    DHCPD | DHCPC | STATIC)
      last_supernode_ip="${SUPERNODE_IP}"
      check_server
      if [[ "${last_supernode_ip}" != "${SUPERNODE_IP}" ]]; then
        LOG_WARNING "检测到 SUPERNODE IP 变化，正在重启 ${last_supernode_ip} - ${SUPERNODE_IP} "
        restart_edge
        break
      fi
      ;;
    *)
      continue
      ;;
    esac
    if [[ "${WATCH_DOG^^}" == "TRUE" ]]; then
      if ! /n2n/n2n_healthcheck.sh >/dev/null 2>&1; then
        LOG_ERROR "守护程序检测到掉线，请检查： $(/n2n/n2n_healthcheck.sh)"
        restart_edge
        break
      fi
    fi
  done
}

main
check_run
