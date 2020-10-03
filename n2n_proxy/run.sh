#!/bin/bash
# set -x

/usr/local/sbin/n2n.sh &
while [ -z $(ifconfig $N2N_TUN | grep "inet addr:" | awk '{print $2}' | cut -c 6-) ]; do
  echo 等待n2n脚本完成
  sleep 1
done
/usr/local/sbin/proxy.sh &
status_check() {
  while true; do
    echo "STATUS - CHECKING"
    sleep 30
    if [[ "$(tail -n 1 /var/log/run.log | grep trying)" ]]; then
      echo "STATUS - RESTART"
      killall tail
    else
      echo "STATUS - RUNNING"
    fi
  done
}
# status_check &s
tail -f /dev/null
