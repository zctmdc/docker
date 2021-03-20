#!/bin/bash
# set -x

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
/usr/local/bin/qshell account "${QINIUYUN_AK}" "${QINIUYUN_SK}" "${QINIUYUN_NAME}"

echo "Start n2n_download"
/usr/local/bin/n2n_download.sh
echo "Finished n2n_download"

echo "Start frp_download"
/usr/local/bin/frp_download.sh
echo "Finished frp_download"

/usr/local/bin/qshell qupload ~/.qshell/qupload.conf

nginx -g "daemon off;"
