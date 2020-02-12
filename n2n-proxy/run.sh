#!/bin/sh
nohup /usr/local/sbin/proxy.sh >> /var/log/run.log 2>&1 &
tail -f -n 20  /var/log/run.log