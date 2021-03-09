#!/bin/bash
# set -x

if [[ -z "$user" ]]; then
  export user="$(uname -n)"
fi
if [[ -z "$subdomain_host" ]]; then
  export subdomain_host="${server_addr}"
fi
if [[ ! -f /etc/frp/frpc.ini || -f /opt/frp/frpc_user.ini ]]; then
  cat >"/etc/frp/frpc.ini" <<EOF
# ========== 客户端基本配置 START ==========

[common]
server_addr = {{ .Envs.server_addr }}
server_port = {{ .Envs.server_port }}
protocol = {{ .Envs.protocol }}
user = {{ .Envs.user }}
token = {{ .Envs.token }}
log_file = {{ .Envs.log_file }}
admin_addr = {{ .Envs.admin_addr }}
admin_port= {{ .Envs.admin_port }}
admin_user = {{ .Envs.admin_user }}
admin_pwd = {{ .Envs.admin_pwd }}
tcp_mux = {{ .Envs.tcp_mux }}

[admin_http_web]
type = http
subdomain = {{ .Envs.user }}-admin
local_ip = localhost
local_port = {{ .Envs.admin_port }}

# ========== 客户端基本配置 END ==========

EOF
  if [[ -f /opt/frp/frpc_user.ini ]]; then
    cat /opt/frp/frpc_user.ini >>/etc/frp/frpc.ini
  fi
fi


if [[ ! -f /etc/frp/frps.ini || -f /opt/frp/frps_user.ini ]]; then
  cat >"/etc/frp/frps.ini" <<EOF
# ========== 服务端基本配置 START ==========

[common]
bind_addr = {{ .Envs.bind_addr }}
bind_port = {{ .Envs.bind_port }}
kcp_bind_port = {{ .Envs.kcp_bind_port }}
bind_udp_port = {{ .Envs.bind_udp_port }}
vhost_http_port = {{ .Envs.vhost_http_port }}
vhost_https_port = {{ .Envs.vhost_https_port }}
dashboard_addr = {{ .Envs.dashboard_addr }}
dashboard_port = {{ .Envs.dashboard_port }}
dashboard_user = {{ .Envs.dashboard_user }}
dashboard_pwd = {{ .Envs.dashboard_pwd }}
token = {{ .Envs.token }}
subdomain_host = {{ .Envs.subdomain_host }}
tcp_mux = {{ .Envs.tcp_mux }}

# ========== 服务端基本配置 END ==========

EOF
  if [[ -f /opt/frp/frps_user.ini ]]; then
    cat /opt/frp/frps_user.ini >>/etc/frp/frps.ini
  fi
fi
