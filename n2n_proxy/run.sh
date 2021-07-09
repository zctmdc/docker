#!/bin/bash
# set -x

/usr/local/sbin/n2n.sh &
# while [ -z $(ifconfig $EDGE_TUN | grep "inet addr:" | awk '{print $2}' | cut -c 6-) ]; do
while [[ -z $(ifconfig $EDGE_TUN | grep "inet" | awk '{print $2}') ]]; do
  echo 等待n2n脚本完成
  sleep 1
done
/usr/local/sbin/proxy.sh &

tail -f /dev/null
