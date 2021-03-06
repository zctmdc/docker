
#!/bin/bash
# set -x

check_uri="http://${user}-admin.${subdomain_host}:${vhost_http_port}/api/status"
frpc_status_code="$(curl -u ${admin_user}:${admin_pwd} -H -I -m 2 -o /dev/null -s -w %{http_code} ${check_uri})"
echo "STATUS : FRPC - ${frpc_status_code}"
if [[ ${frpc_status_code} != 200 ]]; then
  exit 1
fi
exit 0
