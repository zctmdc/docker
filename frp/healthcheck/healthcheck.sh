#!/bin/bash

curPath=$(readlink -f "$(dirname "$0")")

bash $curPath/healthcheck-frps.sh
frps_check_code=$?

bash $curPath/healthcheck-frpc.sh
frpc_check_code=$?

if [[ ${frps_check_code} != 0 || ${frpc_check_code} != 0 ]]; then
    exit 1
fi
