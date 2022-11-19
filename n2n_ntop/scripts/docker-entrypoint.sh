#!/bin/bash

# set -x
app="${1}"
conf_file="${2}"

if [[ -z "$@" ]]; then
    . init_logger.sh
    if [[ -f /n2n/conf/edge.conf ]]; then
        app="edge"
        conf_file="/n2n/conf/edge.conf"
    elif [[ -f /n2n/conf/supernode.conf ]]; then
        app="supernode"
        conf_file="/n2n/conf/supernode.conf"
    else
        if [[ "${MODE}" == "SUPERNODE" ]]; then
            app="supernode"
        # elif [[ "$(echo ${MODE} | grep -E '^(DHCPD)|(DHCPC)|(STATIC)$')" ]]; then
        #     app="edge"
        else
            app="edge"
        fi
        conf_file="/tmp/conf_file_env.conf"
        . conf_save.sh
        CONF_SAVE ${conf_file}
        LOG_INFO "解析环境变量到配置文件: ${conf_file}"
    fi
    LOG_INFO "检测到配置文件: ${conf_file}"
    LOG_INFO "app: ${app}"
    echo ${conf_file} >/tmp/conf_file_from_exec_params.conf
fi

if [[ -n "$(echo ${app} | grep -E '^(/usr/local/sbin/)?(edge)|(supernode)$')" && -n "${conf_file}" && -z "$(echo ${@:2} | grep -E '^(-h)|(--help)$')" ]]; then
    . init_logger.sh
    . init_version.sh
    . conf_read.sh

    INIT_VERSION
    EXEC_PARAMS=" ${@:2}"
    if [[ -n "${@:2}" ]]; then
        LOG_INFO "${EXEC_PARAMS}"
        s_EXEC_PARAMS="${EXEC_PARAMS// -/'\n-'}"
        f_EXEC_PARAMS=$(echo -e "${s_EXEC_PARAMS}")
        # echo "${f_EXEC_PARAMS}"
        echo -e "${f_EXEC_PARAMS}" >>/tmp/conf_file_from_exec_params.conf
    fi
    CONF_READ /tmp/conf_file_from_exec_params.conf

    EDGE_TUN="${cf_EDGE_TUN:-${EDGE_TUN}}"
    EDGE_IP="${cf_EDGE_IP:-${EDGE_IP}}"
    EDGE_COMMUNITY="${cf_EDGE_COMMUNITY:-${EDGE_COMMUNITY}}"
    EDGE_KEY="${cf_EDGE_KEY:-${EDGE_KEY}}"
    EDGE_ENCRYPTION="${cf_EDGE_ENCRYPTION:-${EDGE_ENCRYPTION}}"
    SUPERNODE_HOST="${cf_SUPERNODE_HOST:-${SUPERNODE_HOST}}"
    SUPERNODE_PORT="${cf_SUPERNODE_PORT:-${SUPERNODE_PORT}}"
    N2N_ARGS="${cf_N2N_ARGS:-${N2N_ARGS}}"

    if [[ -n "$(echo ${app} | grep -E '^(/usr/local/sbin/)?edge$')" ]]; then
        if [[ "${EDGE_IP,,}" =~ "dhcp" ]]; then
            MODE="${MODE:-DHCPC}"
        elif [[ -n "$(ls /n2n/conf/ | grep -E '.?dhcpd.conf')" ]]; then
            MODE="${MODE:-DHCPD}"
        else
            MODE="${MODE:-STATIC}"
        fi
    elif [[ -n "$(echo ${app} | grep -E '^(/usr/local/sbin/)?supernode$')" ]]; then
        MODE="${MODE:-SUPERNODE}"
        if [[ -n "${SUPERNODE_PORT_V3}" ]]; then
            if [[ -n "${SUPERNODE_HOST}" && -n "${SUPERNODE_PORT}" ]]; then
                N2N_ARGS="${N2N_ARGS} -l ${SUPERNODE_HOST}:${SUPERNODE_PORT}"
            fi
            SUPERNODE_PORT="${SUPERNODE_PORT_V3}"
        fi
    fi
    if [[ -z "${EDGE_TUN}" ]]; then
        EDGE_TUN="$(hostname)"
    fi
    if [[ "${USE_DEFALT_ARGS^^}" == "TRUE" ]]; then
        LOG_INFO "USE_defalt_args=${USE_DEFALT_ARGS}"
        . append_defalt_args.sh
    fi

    LOG_INFO "MODE: ${MODE}"
    LOG_INFO "EDGE_TUN: ${EDGE_TUN}"
    LOG_INFO "EDGE_IP: ${EDGE_IP}"
    LOG_INFO "EDGE_COMMUNITY: ${EDGE_COMMUNITY}"
    LOG_INFO "EDGE_KEY: ${EDGE_KEY}"
    LOG_INFO "EDGE_ENCRYPTION: ${EDGE_ENCRYPTION}"
    LOG_INFO "SUPERNODE_HOST: ${SUPERNODE_HOST}"
    LOG_INFO "SUPERNODE_PORT: ${SUPERNODE_PORT}"
    LOG_INFO "N2N_ARGS: ${N2N_ARGS}"

    echo "MODE='${MODE}'" >>/n2n/environment
    echo "EDGE_TUN='${EDGE_TUN}'" >>/n2n/environment
    echo "EDGE_IP='${EDGE_IP}'" >>/n2n/environment
    echo "EDGE_COMMUNITY='${EDGE_COMMUNITY}'" >>/n2n/environment
    echo "EDGE_KEY='${EDGE_KEY}'" >>/n2n/environment
    echo "SUPERNODE_HOST='${SUPERNODE_HOST}'" >>/n2n/environment
    echo "SUPERNODE_PORT='${SUPERNODE_PORT}'" >>/n2n/environment
    echo "N2N_ARGS='${N2N_ARGS}'" >>/n2n/environment
    chmod +x /n2n/environment
    sh -c ./run_n2n.sh
fi

exec "$@"
