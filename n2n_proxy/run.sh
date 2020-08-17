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
  if [[ "$(tail -n 1 n2n.log | grep trying)" ]]; then
    echo "RESTART"
    killall edge
    touch /var/log/proxy.log
    nohup /usr/local/sbin/n2n.sh >>/var/log/proxy.log 2>&1 &
    while [ -z $(ifconfig $N2N_TUN | grep "inet addr:" | awk '{print $2}' | cut -c 6-) ]; do
      echo 等待n2n脚本完成 >>/var/log/run.log
      sleep 1
    done
    touch /var/log/run.log
    nohup /usr/local/sbin/proxy.sh >>/var/log/run.log 2>&1 &

  else
    echo "RUNNING"
  fi
}
tail -f -n 20 /var/log/run.log
