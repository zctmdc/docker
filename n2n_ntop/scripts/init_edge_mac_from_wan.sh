#!/bin/bash

# set -x
. init_logger.sh

INIT_EDGE_MAC_FROM_WAN() {
  if [[ -n "$GET_MAC_FROM_WAN" ]]; then
    return
  fi
  ignore_Iface="ztbpaislgc|docker"
  lan_eth=$(busybox route -ne | grep 0.0.0.0 | grep -Ev "$ignore_Iface" | tail -n 1 | awk '{print $8}')
  lan_mac=$(cat /sys/class/net/$lan_eth/address)
  lan_mac_prefix=${lan_mac%:*}
  if [[ $(echo $(expr $((16#${lan_mac##*:})) - 1) | awk '{printf "%x\n",$0}') != 0 ]]; then
    lan_mac_suffix=$(echo $(expr $((16#${lan_mac##*:})) - 1) | awk '{printf "%02x\n",$0}')
  else
    lan_mac_suffix=$(echo $(expr $(echo 0x${lan_mac##*:} | awk '{printf "%d\n",$0}') - 1) | awk '{printf "%02x\n",$0}')
  fi
  EDGE_MAC="${lan_mac_prefix}:${lan_mac_suffix}"
}
