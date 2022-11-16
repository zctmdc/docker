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
    EDGE_TUN="${cf_EDGE_TUN}"
    EDGE_IP="${cf_EDGE_IP}"
    EDGE_COMMUNITY="${cf_EDGE_COMMUNITY}"
    EDGE_KEY="${cf_EDGE_KEY}"
    EDGE_ENCRYPTION="${cf_EDGE_ENCRYPTION}"
    SUPERNODE_HOST="${cf_SUPERNODE_HOST}"
    SUPERNODE_PORT="${cf_SUPERNODE_PORT}"
    N2N_ARGS="${cf_N2N_ARGS}"

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

            case "${VERSION_B_S_rC%%_*}" in
            "v1")
                N2N_ARGS="${N2N_ARGS} -br"
                ;;
            "v2")
                N2N_ARGS="${N2N_ARGS} -EfrA"
                ;;
            "v2s")
                N2N_ARGS="${N2N_ARGS} -bfr -L auto"
                ;;
            "v3")
                N2N_ARGS="${N2N_ARGS} -Efr -e auto"
                ;;
            esac
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
    touch /n2n/environment
    echo "export MODE='${MODE}'" >>/n2n/environment
    echo "export EDGE_TUN='${EDGE_TUN}'" >>/n2n/environment
    echo "export EDGE_IP='${EDGE_IP}'" >>/n2n/environment
    echo "export EDGE_COMMUNITY='${EDGE_COMMUNITY}'" >>/n2n/environment
    echo "export EDGE_KEY='${EDGE_KEY}'" >>/n2n/environment
    echo "export SUPERNODE_HOST='${SUPERNODE_HOST}'" >>/n2n/environment
    echo "export SUPERNODE_PORT='${SUPERNODE_PORT}'" >>/n2n/environment
    echo "export N2N_ARGS='${N2N_ARGS}'" >>/n2n/environment
    chmod +x /n2n/environment
    . run_n2n.sh
fi

exec "$@"
