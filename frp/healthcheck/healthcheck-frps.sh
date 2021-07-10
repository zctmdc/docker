#!/bin/bash

LOG_INFO() {
  echo -e "\033[0;32m[INFO] $* \033[0m"
}
LOG_ERROR() {
  echo -e "\033[0;31m[ERROR] $* \033[0m"
}
LOG_WARNING() {
  echo -e "\033[0;33m[WARNING] $* \033[0m"
}

if [[ -z $(ps -e -fx | grep -v grep | grep -v healthcheck | grep frps) ]]; then
  LOG_ERROR "FRPS is not running"
fi
http_code=$(curl -u ${ADMIN_USER}:${ADMIN_PWD} -H -I -m 2 -o /dev/null -s -w %{http_code} http://${SUBDOMAIN_HOST}:${ADMIN_PORT}/api/serverinfo)
if [[ ${http_code} == 000 ]]; then
  LOG_ERROR "FRPS Dashboard check faild, please check ENV value : \${SUBDOMAIN_HOST}:\${ADMIN_PORT}"
  exit 11
elif [[ $http_code == 401 ]]; then
  LOG_ERROR "FRPS Dashboard 401 Unauthorized, please check ENV value : \${ADMIN_USER}:\${ADMIN_PWD}"
  exit 11
elif [[ $http_code != 200 ]]; then
  LOG_ERROR "FRPS Dashboard check faild, please check : http://${SUBDOMAIN_HOST}:${ADMIN_PORT}"
  exit 11
fi
LOG_INFO "FRPS check PASS"
exit 0
