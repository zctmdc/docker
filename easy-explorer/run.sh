#!/bin/bash
set -x
nohup /usr/local/sbin/easy-explorer.sh >> /var/log/run.log 2>&1 &
tail -f /var/log/run.log
