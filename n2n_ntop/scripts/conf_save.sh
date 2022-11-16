#!/bin/bash

# set -x
. init_logger.sh


if [[ "${MODE^^}" == "SUPERNODE" ]]; then
    conf_file='/etc/n2n/supernode.conf'
elif [[ -n "$(echo ${MODE^^} | grep -E '^(DHCPC)|(DHCPD)|(STATIC)')" ]]; then
    conf_file='/etc/n2n/supernode.conf'
else
    LOG_ERROR_WAIT_EXIT "错误, 未知模式: ${MODE}"
fi

if [[ -f "${conf_file}" ]]; then
    return
fi

mkdir -p /etc/n2n/
touch ${conf_file}

if [[ -n "${EDGE_TUN}" ]]; then
    echo "-d=${EDGE_TUN}" >>${conf_file}
fi

if [[ -n "${EDGE_IP}" ]]; then
    echo "-a=${EDGE_IP}" >>${conf_file}
fi

if [[ -n "${EDGE_COMMUNITY}" ]]; then
    echo "-c=${EDGE_COMMUNITY}" >>${conf_file}
fi

if [[ -n "${EDGE_KEY}" && "${EDGE_ENCRYPTION}" != "-A1" ]]; then
    echo "-k=${EDGE_KEY}" >>${conf_file}
    echo "${EDGE_ENCRYPTION}" >>${conf_file}
fi

if [[ -n "${EDGE_KEY}" ]]; then
    echo "-k=${EDGE_KEY}" >>${conf_file}
fi

if [[ -n "${SUPERNODE_HOST}" && -n "${SUPERNODE_PORT}" ]]; then
    echo "-l=${SUPERNODE_HOST}${SUPERNODE_PORT}" >>${conf_file}
fi

if [[ -n "${N2N_ARGS}" ]]; then
    echo "-k=${N2N_ARGS}" >>${conf_file}
fi

echo "-f" >>${conf_file}
