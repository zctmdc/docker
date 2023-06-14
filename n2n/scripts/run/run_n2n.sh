#!/bin/bash

# set -x

. init_logger.sh
. init_version.sh

cp /usr/share/zoneinfo/${TZ} /etc/localtime
echo "${TZ}" > /etc/timezone \
dpkg-reconfigure -f noninteractive tzdata  

MODE=$(echo "${MODE}" | tr '[a-z]' '[A-Z]')
LOG_INFO "MODE=${MODE}"

if [[ -n "${EDGE_ENCRYPTION}" && "${EDGE_ENCRYPTION:0:1}" != "-" ]]; then
  EDGE_ENCRYPTION="-${EDGE_ENCRYPTION}"
fi
LOG_INFO "EDGE_ENCRYPTION=${EDGE_ENCRYPTION}"

# N2N_ARGS=$(echo "${N2N_ARGS}")
# if [[ -n "${N2N_ARGS}" && "${N2N_ARGS:0:1}" != "-" ]]; then
#   N2N_ARGS="-${N2N_ARGS}"
# fi
LOG_INFO "N2N_ARGS=${N2N_ARGS}"

check_server() {
  if busybox ping -4 -c 1 -w 3 ${SUPERNODE_HOST} >/dev/null 2>&1; then
    SUPERNODE_IP=$(busybox ping -4 -c 1 -w 3 ${SUPERNODE_HOST} | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
    LOG_INFO "SUPERNODE_IP 获取成功: ${SUPERNODE_IP} - ping"
  elif nslookup ${SUPERNODE_HOST} 223.5.5.5 >/dev/null 2>&1; then
    SUPERNODE_IP=$(busybox nslookup -type=a ${SUPERNODE_HOST} 223.5.5.5 | grep -v 223.5.5.5 | grep ddress | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
    LOG_INFO "SUPERNODE_IP 获取成功: ${SUPERNODE_IP} - nslookup"
  else
    SUPERNODE_IP=${SUPERNODE_HOST}
    LOG_WARNING "SUPERNODE_IP RAW: ${SUPERNODE_IP}"
  fi
}

check_mac_address() {
  if [[ "${GET_MAC_FROM_WAN^^}" == 'TRUE' ]]; then
    source init_edge_mac_from_wan.sh
    INIT_EDGE_MAC_FROM_WAN
  fi
  if [[ -n "${EDGE_MAC}" ]]; then
    # 判断 $EDGE_MAC 是否为有效MAC地址
    if [[ "${EDGE_MAC}" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
      EDGE_MAC=$(echo $EDGE_MAC | tr '[a-z]' '[A-Z]')
    else
      EDGE_MAC=""
    fi
  fi
}
init_dhcpd_conf() {
  IP_PREFIX=$(echo "${EDGE_IP}" | grep -Eo "([0-9]{1,3}[\.]){3}")
  mkdir -p /etc/dhcp/
  if [ -f "/n2n/conf/dhcpd.conf" ]; then
    touch /var/lib/dhcp/dhcpd.leases
    cp /n2n/conf/dhcpd.conf /etc/dhcp/dhcpd.conf
  elif [ -f "/n2n/conf/udhcpd.conf" ]; then
    touch /var/lib/misc/udhcpd.leases
    cp /n2n/conf/udhcpd.conf /etc/dhcp/udhcpd.conf
    echo "interface ${EDGE_TUN}" >>/etc/dhcp/udhcpd.conf
  else
    touch /var/lib/dhcp/dhcpd.leases
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
run_dhcpd() {
  init_dhcpd_conf
  LOG_INFO 'DHCPD 服务启动中'
  if [ -f '/var/run/dhcpd.pid' ]; then
    rm -f /var/run/dhcpd.pid
  fi
  if [ -f "/etc/dhcp/dhcpd.conf" ]; then
    dhcpd -f -d "${EDGE_TUN}" &
  elif [ -f "/etc/dhcp/udhcpd.conf" ]; then
    busybox udhcpd -f /etc/dhcp/udhcpd.conf &
  fi
}
run_dhcpc() {
  LOG_RUN dhclient -x
  LOG_RUN dhclient -d --dad-wait-time 5 ${EDGE_TUN} &
}
check_edge() {
  TOTLA_WAIT_TIME=$((30))
  startTime=$(date +%Y%m%d-%H:%M:%S)
  startTime_s=$(date +%s)
  while true; do
    nowTime=$(date +%Y%m%d-%H:%M:%S)
    nowTime_s=$(date +%s)
    sumTime=$(($nowTime_s - $startTime_s))
    LOG_WARNING "启动等待 ${sumTime}/${TOTLA_WAIT_TIME}"
    if [[ ${sumTime} -gt ${TOTLA_WAIT_TIME} ]]; then
      LOG_ERROR "启动超时"
      exit 1
    fi
    if [[ ! -f /sys/class/net/${EDGE_TUN}/address ]]; then
      LOG_WARNING "等待启动: ${EDGE_TUN}"
      sleep 1
      continue
    fi
    if [[ "${MODE}" == "DHCPC" ]]; then
      run_dhcpc
      sleep 5
    fi
    if [[ -z "$(ifconfig ${EDGE_TUN} | grep "inet" | awk '{print $2}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}')" ]]; then
      LOG_WARNING "未获得IP: ${EDGE_TUN}"
      continue
    fi
    LOG_INFO "启动完毕: ${EDGE_TUN} \n\n$(ifconfig ${EDGE_TUN})"
    break
  done
}
run_edge() {
  # init_edge_mac_address
  if [[ -n "${SUPERNODE_IP}" && -n "${SUPERNODE_PORT}" ]]; then
    SUPERNODE_SERVER="${SUPERNODE_IP}:${SUPERNODE_PORT}"
  fi
  LOG_RUN "edge ${EDGE_TUN:+ -d ${EDGE_TUN}} ${EDGE_MAC:+ -m ${EDGE_MAC}} ${EDGE_IP_AGE:+ -a ${EDGE_IP_AGE}} ${EDGE_COMMUNITY:+ -c ${EDGE_COMMUNITY}} ${SUPERNODE_SERVER:+ -l ${SUPERNODE_SERVER}}  ${EDGE_KEY:+ -k ${EDGE_KEY}} ${N2N_ARGS} ${EDGE_KEY:+ ${EDGE_ENCRYPTION}}" &
}

mode_dhcpd() {
  LOG_INFO "${MODE} -- DHCPD 服务器模式"
  # EDGE_IP=`echo $EDGE_IP | grep -Eo "([0-9]{1,3}[\.]){3}"`1
  EDGE_IP_AGE="${EDGE_IP}"
  check_mac_address
  run_edge
  check_edge
  run_dhcpd
}

mode_dhcpc() {
  LOG_INFO "${MODE} -- DHCPC客户端模式"
  if [[ "${EDGE_IP}" =~ "dhcp" ]]; then
    EDGE_IP_AGE="${EDGE_IP}"
  else
    EDGE_IP_AGE="dhcp:0.0.0.0"
    if [[ ! "${N2N_ARGS}" =~ "r" ]]; then
      N2N_ARGS="${N2N_ARGS} -r"
    fi
  fi
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

restart_edge() {
  LOG_RUN dhclient -x
  busybox killall edge
  busybox killall dhcpd
  busybox killall udhcpd
  sleep 3
  busybox killall edge
  sleep 2
  main
}
check_run() {
  LOG_INFO "启动程序执行完毕，守护程序启动。"
  while true; do
    sleep 15
    case ${MODE} in
    DHCPD | DHCPC | STATIC)
      last_supernode_ip="${SUPERNODE_IP}"
      check_server > /dev/null
      if [[ "${last_supernode_ip}" != "${SUPERNODE_IP}" && "${SUPERNODE_IP}" != "${SUPERNODE_HOST}" && "${last_supernode_ip}" != "${SUPERNODE_HOST}" ]]; then
        LOG_WARNING "检测到 SUPERNODE IP 变化，正在重启 '${last_supernode_ip}' - '${SUPERNODE_IP}' "
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
        LOG_ERROR "守护程序检测到掉线，请检查：\n$(/n2n/n2n_healthcheck.sh)"
        restart_edge
        break
      fi
    fi
  done
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
main
check_run