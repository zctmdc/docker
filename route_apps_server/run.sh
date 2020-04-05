#!/bin/bash
set -x
touch /var/log/run.log
nohup /usr/local/sbin/frp_download.sh >>/var/log/run.log 2>&1 &
sleep 1
nohup /usr/local/sbin/n2n_download.sh >>/var/log/run.log 2>&1 &
sleep 1
nohup /usr/local/sbin/file_server.sh >>/var/log/run.log 2>&1 &
tail -f -n 20 /var/log/run.log
