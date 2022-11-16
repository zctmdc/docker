#!/bin/bash

# set -x
app="${1}"
conf_file="${2}"
if [[ -z "$@" ]]; then
    if [[ -f /n2n/conf/edge.conf ]]; then
        app="edge"
        conf_file=/n2n/conf/edge.conf
    elif [[ -f /n2n/conf/supernode.conf ]]; then
        app="supernode"
        conf_file=/n2n/conf/supernode.conf
    else
        . run_n2n.sh
    fi
fi
if [[ -n "$(echo ${app} | grep -E '^(/usr/local/sbin/)?(edge)|(supernode)$')" ]]; then
    . init_logger.sh
    . init_version.sh
    INIT_VERSION
    shift
    if [[ -f "${conf_file}" && "${conf_file##*.}" == "conf" ]]; then
        . conf_read.sh "${conf_file}"
        shift
    fi
    N2N_ARGS="${N2N_ARGS} ${@}"
    if [[ -n "$(echo ${app} | grep -E '^(/usr/local/sbin/)?edge$')" ]]; then
        if [[ "${EDGE_IP^^}" =~ "DHCP" ]]; then
            MODE="DHCPC"
        elif [[ -n "$(ls ${conf_file%/*} | grep -E '.?dhcpd.conf')" ]]; then
            MODE="DHCPD"
        else
            MODE="STATIC"
        fi
        if [[ "${USE_DEFALT_ARG,,}" == "true" ]]; then
            if [[ "${VERSION_B_S_rC%%_*}" == "v1" ]]; then
                N2N_ARGS="${N2N_ARGS} -br"
            fi
            if [[ "${VERSION_B_S_rC%%_*}" == "v2" ]]; then
                N2N_ARGS="${N2N_ARGS} -EfrA"
            fi
            if [[ "${VERSION_B_S_rC%%_*}" == "v2s" ]]; then
                N2N_ARGS="${N2N_ARGS} -bfr -L auto"
            fi
            if [[ "${VERSION_B_S_rC%%_*}" == "v3" ]]; then
                N2N_ARGS="${N2N_ARGS} -Efr -e auto"
            fi
        fi
    elif [[ -n "$(echo ${app} | grep -E '^(/usr/local/sbin/)?supernode$')" ]]; then
        MODE="SUPERNODE"
        if [[ -n "${SUPERNODE_PORT_V3}" ]]; then
            if [[ -n "${SUPERNODE_HOST}" && -n "${SUPERNODE_PORT}" ]]; then
                N2N_ARGS="${N2N_ARGS} -l ${SUPERNODE_HOST}:${SUPERNODE_PORT}"
            fi
            SUPERNODE_PORT="${SUPERNODE_PORT_V3}"
        fi
        if [[ "${USE_DEFALT_ARG,,}" == "true" ]]; then
            if [[ "${VERSION_B_S_rC%%_*}" != "v1" ]]; then
                N2N_ARGS="${N2N_ARGS} -f"
            fi
        fi
    fi
    N2N_ARGS="$(echo ${N2N_ARGS})"
    LOG_INFO "MODE: ${MODE}"
    LOG_INFO "EDGE_TUN: ${EDGE_TUN}"
    LOG_INFO "EDGE_IP: ${EDGE_IP}"
    LOG_INFO "EDGE_COMMUNITY: ${EDGE_COMMUNITY}"
    LOG_INFO "EDGE_KEY: ${EDGE_KEY}"
    LOG_INFO "EDGE_ENCRYPTION: ${EDGE_ENCRYPTION}"
    LOG_INFO "SUPERNODE_HOST: ${SUPERNODE_HOST}"
    LOG_INFO "SUPERNODE_PORT: ${SUPERNODE_PORT}"
    LOG_INFO "N2N_ARGS: ${N2N_ARGS}"
    . run_n2n.sh
fi

exec "$@"
