#!/bin/bash
set -x

touch /var/log/run.log

apk add tsocks

cat >"/etc/tsocks.conf" <<EOF
local = 110.53.0.0/255.255.0.0
server = home.zctmdc.cn
server_type = 5
server_port = 10808
EOF

nohup tsocks /usr/local/sbin/frp_download.sh >>/var/log/run.log 2>&1 &
sleep 1
nohup tsocks /usr/local/sbin/n2n_download.sh >>/var/log/run.log 2>&1 &
sleep 1
nohup /usr/local/sbin/file_server.sh >>/var/log/run.log 2>&1 &
tail -f -n 20 /var/log/run.log
