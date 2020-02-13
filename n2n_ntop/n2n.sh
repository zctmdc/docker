#!/bin/sh

set -x
MODE=$(echo "$MODE" | tr '[a-z]' '[A-Z]')
echo MODE=$(echo "$MODE" | tr '[a-z]' '[A-Z]') >> /var/log/n2n.log
if [[  "${N2N_ARGS:0:1}" != "-" ]]; then
    N2N_ARGS=-${N2N_ARGS}
fi
echo N2N_ARGS=${N2N_ARGS}>> /var/log/n2n.log

mode_supernode() {
    echo  ${MODE} -- 超级节点模式  >> /var/log/n2n.log
    supernode -h
    nohup \
      supernode \
        -l $SUPERNODE_PORT \
        $N2N_ARGS \
    >> /var/log/n2n.log 2>&1 &
}
init_dhcpd_conf()
{
IP_PREFIX=`echo $N2N_IP | grep -Eo "([0-9]{1,3}[\.]){3}"`
if [ ! -f "/etc/dhcp/dhcpd.conf" ] ;then
mkdir -p /etc/dhcp/
cat > "/etc/dhcp/dhcpd.conf" <<    EOF
  authoritative;
  ddns-update-style none;
  ignore client-updates;
  subnet ${IP_PREFIX}0 netmask 255.255.255.0 {
    range ${IP_PREFIX}60 ${IP_PREFIX}180;
    default-lease-time 600;
    max-lease-time 7200;
  }
EOF
fi
}
mode_dhcpd() {
    echo ${MODE} -- DHCPD 服务器模式  >> /var/log/n2n.log
    edge -h
    # STATIC_IP=`echo $STATIC_IP | grep -Eo "([0-9]{1,3}[\.]){3}"`1
    nohup \
      edge \
        -d $N2N_INTERFACE \
        -a $STATIC_IP \
        -c $N2N_GROUP \
        -k $N2N_PASS \
        -l $N2N_SERVER \
        -f \
        ${N2N_ARGS} \
      >> /var/log/n2n.log 2>&1 &
    init_dhcpd_conf
    echo  DHCPD 服务启动中  >> /var/log/n2n.log
    nohup dhcpd -f -d  $N2N_INTERFACE >> /var/log/n2n.log 2>&1 &
}
mode_dhcp() {
    echo ${MODE} -- DHCP客户端模式  >> /var/log/n2n.log
    edge -h
    nohup \
      edge \
        -d $N2N_INTERFACE \
        -a dhcp:0.0.0.0 \
        -c $N2N_GROUP \
        -k $N2N_PASS \
        -l $N2N_SERVER \
        -rf \
        ${N2N_ARGS} \
      >> /var/log/n2n.log 2>&1 &
    while [ -z `ifconfig $N2N_INTERFACE| grep "inet addr:" | awk '{print $2}' | cut -c 6-` ]
    do
      dhclient $N2N_INTERFACE
    done
}
mode_static() {
    echo ${MODE} -- 静态地址模式  >> /var/log/n2n.log
    edge -h
    nohup \
      edge \
        -d $N2N_INTERFACE \
        -a $STATIC_IP \
        -c $N2N_GROUP \
        -k $N2N_PASS \
        -l $N2N_SERVER \
        -f \
        ${N2N_ARGS} \
      >> /var/log/n2n.log 2>&1 &
    while [ -z `ifconfig $N2N_INTERFACE| grep "inet addr:" | awk '{print $2}' | cut -c 6-` ]
    do
      sleep 1
    done
}
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
    echo ${MODE} -- 判断失败,使用DHCP模式 >> /var/log/n2n.log
    mode_dhcp
  ;;
esac
ifconfig
tail -f -n 20  /var/log/n2n.log