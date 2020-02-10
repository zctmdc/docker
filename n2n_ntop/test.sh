#!/bin/sh

#docker run  --privileged --rm -ti alpine sh
#docker exec -it alpine_sh sh
############ build start############
set -x

cd /tmp/
apk update
apk upgrade
apk add --update --no-cache --virtual .build-deps build-base  cmake  git  linux-headers  openssl-dev
git clone https://github.com/ntop/n2n.git
cd n2n
cmake . && make install
apk del .build-deps
cd /tmp
rm -rf ./*
############ build end############

############ evn start############
MODE="STATIC"
SUPERNODE_PORT="10086"
N2N_INTERFACE="edge0"
STATIC_IP="10.0.0.10"
N2N_GROUP="zctmdc_dhcp"
N2N_PASS="zctmdc_dhcp"
N2N_SERVER="n2n.lucktu.com:10086"
apk add --update --no-cache openssl dhclient dhcp-server-ldap
touch /var/lib/dhcp/dhcpd.leases
############ evn end############


############ RUN start############
MODE=$(echo $MODE | tr '[a-z]' '[A-Z]')
if [[$MODE == *"SUPERNODE"* ]]; then
    nohup \
      supernode \
      -l $SUPERNODE_PORT \
      -f \
      >> /var/log/run.log 2>&1 &
elif [[ $MODE == *"DHCPD"* ]]; then
    nohup \
      edge \
      -d $N2N_INTERFACE \
      -a $STATIC_IP \
      -c $N2N_GROUP \
      -k $N2N_PASS \
      -l $N2N_SERVER \
      -Arf \
      >> /var/log/run.log 2>&1 &
    while [ -z `ifconfig $N2N_INTERFACE| grep "inet addr:" | awk '{print $2}' | cut -c 6-` ]
    do
        dhclient $N2N_INTERFACE
    done
elif [[ $MODE == *"DHCP"* ]]; then
    nohup \
      edge \
      -d $N2N_INTERFACE \
      -a dhcp:0.0.0.0 \
      -c $N2N_GROUP \
      -k $N2N_PASS \
      -l $N2N_SERVER \
      -Arf \
      >> /var/log/run.log 2>&1 &
    while [ -z `ifconfig $N2N_INTERFACE| grep "inet addr:" | awk '{print $2}' | cut -c 6-` ]
    do
    dhclient $N2N_INTERFACE
    done
    tail -f -n 20  /var/log/run.log
elif [[ $MODE == *"STATIC"* ]]; then
    nohup \
      edge \
      -d $N2N_INTERFACE \
      -a $STATIC_IP \
      -c $N2N_GROUP \
      -k $N2N_PASS \
      -l $N2N_SERVER \
      -Arf \
      >> /var/log/run.log 2>&1 &
fi
ifconfig
tail -f -n 20  /var/log/run.log
############ RUN end############

# docker build . -t zctmdc/n2n_ntop:latest

