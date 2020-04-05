#!/bin/bash
set -x
nohup /usr/local/sbin/mount_smb.sh >>/var/log/run.log 2>&1 &
nohup /usr/local/sbin/easy-explorer.sh >>/var/log/run.log 2>&1 &
tail -f -n 20 /var/log/run.log
