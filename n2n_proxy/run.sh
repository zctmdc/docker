#!/bin/bash
set -x
touch /var/log/proxy.log
nohup /usr/local/sbin/n2n.sh >>/var/log/proxy.log 2>&1 &
while [ -z $(ifconfig $N2N_TUN | grep "inet addr:" | awk '{print $2}' | cut -c 6-) ]; do
  echo 等待n2n脚本完成 >>/var/log/run.log
  sleep 1
done
touch /var/log/run.log
nohup /usr/local/sbin/proxy.sh >>/var/log/run.log 2>&1 &

status_check() {
  while true; do
    echo "STATUS - CHECKING" >>/var/log/run.log
    sleep 30
    if [[ "$(tail -n 1 /var/log/run.log | grep trying)" ]]; then
      echo "STATUS - RESTART" >>/var/log/run.log
      killall tail
    else
      echo "STATUS - RUNNING" >>/var/log/run.log
    fi
  done
}
status_check &

tail -f -n 20 /var/log/run.log
