check_status() {
  while true; do
    sleep 30
    if [[ ${WATCH_STATUS} != true ]]; then
      continue
    fi
    /usr/local/bin/healthcheck_frps.sh
    if [ "$FRPC_ENABLE" == true ]; then
      if ! /usr/local/bin/healthcheck_frpc.sh 2>&1; then
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
    echo "FRPC version - $(/usr/local/bin/frpc -v)"
    /usr/local/bin/frpc -c /etc/frp/frpc.ini &
  fi
}
run_frps() {
  if [ "$FRPS_ENABLE" == true ]; then
    echo "RUN FRPS"
    killall frps
    sleep 5
    echo "FRPS version - $(/usr/local/bin/frpc -v)"
    /usr/local/bin/frps -c /etc/frp/frps.ini &
  fi
}
down_latest() {
  if [[ "$DOWN_LATEST" == true ]]; then
    return
  fi
  if [ -z "${cdn_uri}" ]; then
    cdn_uris='
http://rt.qiniu.zctmdc.cn#七牛云储存
http://zctmdc.xicp.io#花生壳-LZtesu
https://ras.lztesu.zctmdc.cn#RAS
https://qiniu.cdn.rt.zctmdc.cn#七牛云CDN-LZtesu
http://rt.zctmdc.cn:17880#N2N-LZtesu
'
    for line in ${cdn_uris}; do
      c_cdn_uri="${line%#*}"
      if [[ -z ${c_cdn_uri} ]]; then
        continue
      fi
      http_status_code="$(curl -H -I -m 2 -o /dev/null -s -w %{http_code} ${c_cdn_uri}/script/main.sh)"
      echo "$c_cdn_uri - ${http_status_code}"
      if [[ "${http_status_code}" == "200" && -z "$cdn_uri" ]]; then
        cdn_uri="${c_cdn_uri}"
      fi
    done
  fi
  echo "使用地址 - ${cdn_uri}"
  frp_latest_version="$(curl -L -s ${cdn_uri}/bin/frp_version.txt)"
  echo "FRP 本地版本 : $(/usr/local/bin/frpc -v) , 最新版本 : ${frp_latest_version}"
  if [[ -z "$cdn_uri" && "$(/usr/local/bin/frpc -v)" != "${frp_latest_version}" ]]; then
    echo "正在更新FRP客户端"
    wget -O /tmp/frpc_linux_amd64 ${cdn_uri}/bin/frpc_linux_amd64
    chmod a+x /tmp/frpc_linux_amd64
    if [[ "$(/tmp/frpc_linux_amd64 -v)" == "${frp_latest_version}" ]]; then
      mv /tmp/frpc_linux_amd64 /usr/local/bin/frpc
      echo "FRPC更新成功"
    else
      echo "FRPC更新失败"
    fi
    echo "正在更新FRP服务端"
    wget -O /tmp/frps_linux_amd64 ${cdn_uri}/bin/frps_linux_amd64
    chmod a+x /tmp/frps_linux_amd64
    if [[ "$(/tmp/frps_linux_amd64 -v)" == "${frp_latest_version}" ]]; then
      mv /tmp/frps_linux_amd64 /usr/local/bin/frps
      echo "FRPS更新成功"
    else
      echo "FRPS更新失败"
    fi
  fi
}
/usr/local/bin/init.sh
down_latest
run_frps
run_frpc
check_status
