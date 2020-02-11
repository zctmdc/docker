#!/bin/sh
set -x
nohup /usr/local/sbin/n2n.sh >> /var/log/proxy.log 2>&1 &
if [[ "${N2N_GW}" == "TRUE" ]] ;then 
    echo  ${N2N_GW} -- 启用转发 >>  /var/log/proxy.log
    route add -net $N2N_DESTINATION gw $N2N_GATEWAY
fi
if [[ "${N2N_NAT}" == "TRUE" ]] ;then 
  echo  ${N2N_NAT} -- 启用NAT >>  /var/log/proxy.log

  lan_eth=$N2N_INTERFACE
  wan_eth="eth0"
  lan_ip=`ifconfig $lan_eth| grep "inet addr:" | awk '{print $2}' | cut -c 6-`
  lan_gateway=`ifconfig $lan_eth |sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p'`1
  wan_ip=`ifconfig $wan_eth| grep "inet addr:" | awk '{print $2}' | cut -c 6-`
  wan_gateway=`ifconfig $wan_eth |sed -n '/inet addr/s/^[^:]*:\(\([0-9]\{1,3\}\.\)\{3\}\).*/\1/p'`1

  sysctl net.ipv4.ip_forward=1
  iptables -A INPUT -i $lan_eth -j ACCEPT
  iptables -A FORWARD -i $wan_eth -j ACCEPT
  iptables -t nat -A POSTROUTING -s $lan_gateway/24 -o $wan_eth -j MASQUERADE
fi
route -n
if [[ "${N2N_PROXY}" == "TRUE" ]] ;then 
  echo  ${N2N_PROXY} -- 启用代理 >>  /var/log/proxy.log
  nohup /bin/gost $PROXY_ARGS  >> /var/log/proxy.log 2>&1 &
fi
tail -f -n 20  /var/log/proxy.log