#!/bin/bash
set -x
touch /var/log/easy-explorer.log
cd /opt/easy-explorer/
echo "$USER_TOKEN"
if [ -f "/etc/easy-explorer/conf.json" ]; then
  echo 检测到配置文件,即将启动
  nohup /usr/local/sbin/easy-explorer -c /etc/easy-explorer/conf.json >>/var/log/easy-explorer.log 2>&1 &
elif [[ "$USER_TOKEN"!="" ]]; then
  echo 检测到用户口令,即将启动
  nohup \
    /usr/local/sbin/easy-explorer \
    -u $USER_TOKEN \
    -userPath /tmp \
    -name LZtesu-docker \
    -share /mnt/share/ \
    >>/var/log/easy-explorer.log 2>&1 &
else
  echo 即将启动,请打开浏览器进行配置
  nohup /usr/local/sbin/easy-explorer >>/var/log/easy-explorer.log 2>&1 &
  nohup tail -f -n 20 /usr/local/sbin/easy-explorer.log >>/var/log/easy-explorer.log 2>&1 &
fi
tail -f -n 20 /var/log/easy-explorer.log
