#!/bin/bash
# set -x


touch /var/log/run.log

apk add tsocks

if ping -c 1 -W 1 proxy_server >/dev/null 2>&1; then
  local_sub=172.0.0.0/255.0.0.0
  ss5_server=proxy_server
  ss5_port=10808
else
  local_sub=110.53.0.0/255.255.0.0
  ss5_server=home.zctmdc.cn
  ss5_port=10808
fi

cat >"/etc/tsocks.conf" <<EOF
local = ${local_sub}
server = ${ss5_server}
server_type = 5
server_port = ${ss5_port}
EOF

/usr/local/bin/qshell account "${QINIUYUN_AK}" "${QINIUYUN_SK}" "${QINIUYUN_NAME}"
cat >~/.qshell/qupload.conf <<EOF
{
  "src_dir": "/tmp/",
  "bucket": "cn-zctmdc-route",
  "skip_path_prefixes": "download,frp,n2n,qshell,.hls",
  "rescan_local": true,
  "overwrite" : true,
  "check_hash" : true
}
EOF

# echo "$(sed "0,/nameserver.*/s//nameserver 119.29.29.29/" /etc/resolv.conf)" >/etc/resolv.conf

tsocks /usr/local/bin/frp_download.sh &
sleep 1
tsocks /usr/local/bin/n2n_download.sh &
sleep 1
/usr/local/sbin/file_server.sh
