#/bin/bash
LOG() {
    echo -e "\t[$*]\t"
}
if [[ -z $(ps -ax | grep -v grep | grep -v healthcheck | grep frps) ]]; then
    LOG FRPS is not running
fi
http_code=$(curl -u $ADMIN_USER:$ADMIN_PWD -H -I -m 2 -o /dev/null -s -w %{http_code} http://$SUBDOMAIN_HOST:$ADMIN_PORT/api/serverinfo)
if [[ $http_code == 000 ]]; then
    LOG FRPS Dashboard check faild, please check ENV value : \$SUBDOMAIN_HOST:\$ADMIN_PORT
    exit 11
elif [[ $http_code == 401 ]]; then
    LOG FRPS Dashboard 401 Unauthorized, please check ENV value : \$ADMIN_USER:\$ADMIN_PWD
    exit 11
elif [[ $http_code != 200 ]]; then
    LOG FRPS Dashboard check faild, please check : http://$SUBDOMAIN_HOST:$ADMIN_PORT
    exit 11
fi
LOG FRPS check PASS
exit 0
