check_uri="http://${server_addr}:${dashboard_port}"
frpc_status_code="$(curl -H -I -m 2 -o /dev/null -s -w %{http_code} ${check_uri})"
echo "STATUS : FRPS - ${frps_status_code}"
if [[ ${frps_status_code} == 404 ]]; then
  exit 1
fi
exit 0
