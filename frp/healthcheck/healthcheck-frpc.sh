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

if [[ -z $(ps -e -f | grep -v grep | grep -v healthcheck | grep frpc) ]]; then
  LOG_WARNING "FRPC is not running"
  exit 0
else
  http_code=$(curl -u ${ADMIN_USER}:${ADMIN_PWD} -H -I -k -m 2 -o /dev/null -s -w %{http_code} --connect-timeout 10 http://localhost:${ADMIN_PORT}/api/status)
  if [[ ${http_code} != 200 ]]; then
    LOG_ERROR "local FRPC adminUI check faild, please check FRPC adminUI - http://localhost:${ADMIN_PORT}/api/status"
    exit 1
  else
    LOG_INFO "local FRPC adminUI check pass"
  fi
fi
http_code=$(curl -u ${ADMIN_USER}:${ADMIN_PWD} -H -I -k -m 2 -o /dev/null -s -w %{http_code} -H "Host: $(hostname -s)-admin.${SUBDOMAIN_HOST}" --connect-timeout 10 http://${SUBDOMAIN_HOST}:${VHOST_HTTP_PORT}/api/status)
if [[ ${http_code} == 000 ]]; then
  LOG_ERROR "FRPC adminUI check faild, please check ENV value - \${SUBDOMAIN_HOST}:\${VHOST_HTTP_PORT} : ${SUBDOMAIN_HOST}:${VHOST_HTTP_PORT}"
  exit 1
elif [[ ${http_code} == 401 ]]; then
  LOG_ERROR "FRPC adminUI Unauthorized [401], please check ENV value - ${ADMIN_USER}:${ADMIN_PWD}"
  exit 1
elif [[ ${http_code} == 404 ]]; then
  LOG_ERROR "FRPC adminUI page not fund [404], please check FRPC adminUI URI - http://$(hostname -s)-admin.${SUBDOMAIN_HOST}:${VHOST_HTTP_PORT}"
  exit 1
elif [[ ${http_code} != 200 ]]; then
  LOG_ERROR "FRPC adminUI check faild, please check FRPC adminUI - http://$(hostname -s)-admin.${SUBDOMAIN_HOST}:${VHOST_HTTP_PORT}"
  exit 1
fi

LOG_INFO "FRPC check PASS"
exit 0
