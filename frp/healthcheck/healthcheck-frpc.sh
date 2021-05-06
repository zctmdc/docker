#/bin/bash
LOG() {
    echo -e "\t[$*]\t"
}
if [[ -z $(ps -a | grep -v grep | grep -v healthcheck | grep frpc) ]]; then
    LOG FRPC is not running
    exit 0
fi
http_code=$(curl -u $ADMIN_USER:$ADMIN_PWD -H -I -m 2 -o /dev/null -s -w %{http_code} http://$(hostname -s).$SUBDOMAIN_HOST:$VHOST_HTTP_PORT/api/status)
if [[ $http_code == 000 ]]; then
    LOG FRPC adminUI check faild, please check ENV value : \$SUBDOMAIN_HOST:\$VHOST_HTTP_PORT
    exit 11
elif [[ $http_code == 401 ]]; then
    LOG FRPC adminUI Unauthorized [401], please check ENV value : \$ADMIN_USER:\$ADMIN_PWD
    exit 11
elif [[ $http_code == 404 ]]; then
    LOG FRPC adminUI page not fund [404], please check : http://$SUBDOMAIN_HOST:$ADMIN_PORT http://$(hostname -s).$SUBDOMAIN_HOST:$VHOST_HTTP_PORT
    exit 11
elif [[ $http_code != 200 ]]; then
    LOG FRPC adminUI check faild, please check : http://$(hostname -s).$SUBDOMAIN_HOST:$VHOST_HTTP_PORT
    exit 11
fi
LOG FRPC check PASS
exit 0
