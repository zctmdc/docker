check_uri="http://${user}-admin.${subdomain_host}:${vhost_http_port}"
frpc_status_code="$(curl -H -I -m 2 -o /dev/null -s -w %{http_code} ${check_uri})"
if [[ $frpc_status_code == 404 ]]; then
  exit 1
fi
exit 0
