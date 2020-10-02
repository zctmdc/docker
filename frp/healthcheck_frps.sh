#!/bin/bash
# set -x

check_uri="http://${server_addr}:${dashboard_port}/api/serverinfo"
frps_status_code="$(curl -u ${dashboard_user}:${dashboard_pwd} -H -I -m 2 -o /dev/null -s -w %{http_code} ${check_uri})"
echo "STATUS : FRPS - ${frps_status_code}"
if [[ ${frps_status_code} != 200 ]]; then
  exit 1
fi
exit 0
