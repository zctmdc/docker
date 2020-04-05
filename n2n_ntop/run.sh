#!/bin/bash
set -x
touch /var/log/run.log
nohup /usr/local/sbin/n2n.sh >>/var/log/run.log 2>&1 &
tail -f -n 20 /var/log/run.log
