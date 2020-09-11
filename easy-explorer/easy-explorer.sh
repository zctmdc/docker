#!/bin/bash
# set -x

cd /opt/easy-explorer/
if [ -f "/etc/easy-explorer/conf.json" ]; then
  echo 检测到配置文件,即将启动
  /usr/local/sbin/easy-explorer -c /etc/easy-explorer/conf.json
elif [[ "$USER_TOKEN"!="" ]]; then
  echo 检测到用户口令 $USER_TOKEN ,即将启动
  /usr/local/sbin/easy-explorer -u $USER_TOKEN -userPath /tmp -name $(uname -n) -share /mnt/share/
else
  echo 即将启动,请打开浏览器进行配置
  /usr/local/sbin/easy-explorer
fi
