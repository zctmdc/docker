#!/bin/bash
set -x
cd /opt/easy_explorer/
echo "$USER_TOKEN"
if [ -f "/etc/easy_explorer/conf.json" ] ;then
  echo 检测到配置文件,即将启动
  nohup /opt/easy_explorer/easy_explorer -c /etc/easy_explorer/conf.json >> /var/log/easy_explorer.log 2>&1 &
elif [[ "$USER_TOKEN"!="" ]] ;then
  echo 检测到用户口令,即将启动
  nohup \
    /opt/easy_explorer/easy_explorer \
      -u $USER_TOKEN \
      -userPath /tmp \
      -name LZtesu-docker \
      -share /mnt/share/ \
  >> /var/log/easy_explorer.log 2>&1 &
else
  echo 即将启动,请打开浏览器进行配置
  nohup /opt/easy_explorer/easy_explorer >> /var/log/easy_explorer.log 2>&1 &
fi
tail -f /var/log/easy_explorer.log
