check_status() {
  while true
  do
  sleep 30
  if [ "$FRPS_ENABLE" == true ]; then
    if /usr/local/bin/healthcheck_frps.sh 2>&1; then
      echo "STATUS - FRPS OK"
    else
      echo "STATUS - FRPS:ERRO"
      run_frps
    fi
  fi
  if [ "$FRPC_ENABLE" == true ]; then
    if /usr/local/bin/healthcheck_frpc.sh 2>&1; then
      echo "STATUS - FRPC OK"
    else
      echo "STATUS - FRPC:ERRO"
      run_frpc
    fi
  fi
  done
}
run_frpc() {
  if [ "$FRPC_ENABLE" == true ]; then
    echo "RUN FRPC"
    killall frpc
    sleep 5
    /usr/local/bin/frpc -c /etc/frp/frpc.ini &
  fi
}
run_frps() {
  if [ "$FRPS_ENABLE" == true ]; then
    echo "RUN FRPS"
    killall frps
    sleep 5
    /usr/local/bin/frps -c /etc/frp/frps.ini &
  fi
}
down_latest() {

  if [[ "$DOWN_LATEST" == true ]]; then
    if [ -z "${cdn_uri}" ]; then
      cdn_uris='
http://rt.qiniu.zctmdc.cn#七牛云储存
http://zctmdc.xicp.io#花生壳-LZtesu
https://ras.lztesu.zctmdc.cn#RAS
https://qiniu.cdn.rt.zctmdc.cn#七牛云CDN-LZtesu
http://rt.zctmdc.cn:17880#N2N-LZtesu
'
      # echo "${cdn_uris}" | while read line; do
      for line in ${cdn_uris}; do
        c_cdn_uri="${line%#*}"
        if [[ -z ${c_cdn_uri} ]]; then
          continue
        fi
        http_status_code="$(curl -H -I -m 2 -o /dev/null -s -w %{http_code} ${c_cdn_uri}/script/main.sh)"
        if [[ "${http_status_code}" == "200" ]]; then
          if [[ -z "$cdn_uri" ]]; then
            cdn_uri="${c_cdn_uri}"
          fi
          echo "$c_cdn_uri - ${http_status_code}"
        else
          echo "$c_cdn_uri - ${http_status_code}"
        fi
      done
    fi
    echo "使用地址 - ${cdn_uri}"
    if [[ "$(/usr/local/bin/frpc -v)" != "$(curl -L -s ${cdn_uri}/bin/frp_version.txt)" ]]; then
      wget -O /tmp/frpc_linux_amd64 ${cdn_uri}/bin/frpc_linux_amd64
      chmod a+x /tmp/frpc_linux_amd64
      mv /tmp/frpc_linux_amd64 /usr/local/bin/frpc
      wget -O /tmp/frps_linux_amd64 ${cdn_uri}/bin/frps_linux_amd64
      chmod a+x /tmp/frps_linux_amd64
      mv /tmp/frps_linux_amd64 /usr/local/bin/frps
    fi
  fi
}
/usr/local/bin/init.sh
down_latest
run_frps
run_frpc
check_status
