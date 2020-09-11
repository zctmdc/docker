#!/bin/bash
# set -x

DEFALS_PATH="/usr/share/nginx/html"
if [ -d ${WORK_PATH} ]; then
  echo "${WORK_PATH} 是目录"
  sed "0,/${DEFALS_PATH//\//\\\/}/s//${WORK_PATH//\//\\\/}/" /etc/nginx/conf.d/default.conf.example >/etc/nginx/conf.d/default.conf
elif [ -f ${WORK_PATH} ]; then
  echo "${WORK_PATH} 是文件"
  mount -o loop ${WORK_PATH} ${WORK_PATH}_mounted
  sed "0,/${DEFALS_PATH//\//\\\/}/s//${WORK_PATH//\//\\\/}_mounted/" /etc/nginx/conf.d/default.conf.example >/etc/nginx/conf.d/default.conf
else
  echo "${WORK_PATH} 不存在"
fi
nginx -g "daemon off;"
