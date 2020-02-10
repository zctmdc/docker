# N2N proxy

基于[zctmdc/n2n_ntop][n2n_ntop]和[pginuerzh/gost][gost]制作的P2P远程代理

只需要开放一个端口,就可以在软件上使用代理,链接远程电脑

## 使用方法

### 测试

```bash
docker run -ti --rm zctmdc/n2n_proxy
```

### 远端/网络共享端

```bash
docker run \
  -d --restart=always \
  --name n2n_proxy_nat \
  --privileged \
  -e MODE="DHCPD" \
  -e STATIC_IP="10.0.0.1" \
  -v path/to/dhcpd.conf:/etc/dhcp/dhcpd.conf:ro
  -e N2N_GROUP="zctmdc_dhcp" \
  -e N2N_PASS="zctmdc_dhcp" \
  -e N2N_SERVER="n2n.lucktu.com:10086" \
  -e N2N_NAT=TRUE \
  zctmdc/n2n_proxy
```

### 近端/代理路口端

```bash
docker run \
  -d --restart=always \
  --name n2n_proxy_nat \
  --privileged \
  -e MODE="DHCP" \
  -e N2N_GROUP="zctmdc_dhcp" \
  -e N2N_PASS="zctmdc_dhcp" \
  -e N2N_SERVER="n2n.lucktu.com:10086" \
  -e N2N_GW="TURE" \
  -e N2N_DESTINATION="192.168.0.0/16" \
  -e N2N_GATEWAY="10.0.0.1"\
  -p 1080:1080 \
  zctmdc/n2n_proxy
```

然后你就可以使用1080端口进行代理,访问远程资料

更多详情参看:[zctmdc/n2n_ntop][n2n_ntop]和[pginuerzh/gost][gost]

[n2n_ntop]:https://hub.docker.com/r/zctmdc/n2n_ntop "n2n-ntop的docker hub地址"

[gost]:https://github.com/ginuerzh/gost "ginuerzh/gost的GITHUB地址"
