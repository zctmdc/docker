#!/bin/bash

# set -x
. init_logger.sh

CONF_READ() {
    if [[ -z "${1}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: CONF_READ: FILE \${1} - 为空"
    fi
    conf_file_read="${1}"
    LOG_INFO "Loading conf: conf_file_read - '${1}'"
    LOG_INFO "RAW DATA START"
    cat ${1}
    LOG_INFO "RAW DATA END"
    while read conf_file_read_line; do
        LOG_INFO "conf_file_read_line: '${conf_file_read_line}'"
        l_conf_file_read_line=(${conf_file_read_line[@]})
        conf_file_read_append=${l_conf_file_read_line[-1]}
        if [[ -f "${conf_file_read_append}" ]]; then
            LOG_INFO "conf_file_read_append: '${conf_file_read_append}'"
            sed -i "s|${conf_file_read_append}||g" ${1}
            if [[ "${conf_file_read_append}" == "${1}" ]]; then
                LOG_WARNING "跳过文件: ${conf_file_read_append}"
                continue
            fi
            CONF_READ ${conf_file_read_append}
        fi
    done < <(cat "${1}" | grep .conf)
    while read arg_line; do
        arg=$(echo "${arg_line}")
        LOG_INFO "arg: '${arg}'"

        arg_key=$(echo "$arg" | grep -Eo '^\-(\-|\w|[0-9])+' | sed 's/\-\+//')
        if [[ -z "${arg_key}" ]]; then
            LOG_WARNING "NO ARG FOUND: '${arg}'"
            continue
        fi
        arg_value="${arg#*${arg_key}}"
        arg_value="$(echo $(echo ${arg_value} | sed 's/^\=//'))"

        LOG_INFO "arg_key: '${arg_key}'"
        LOG_INFO "arg_value: '${arg_value}'"
        LOG_INFO "------"
        case "${arg_key}" in
        d | tap-device)
            cf_EDGE_TUN=${arg_value}
            LOG_INFO "cf_EDGE_TUN: '${cf_EDGE_TUN}'"
            # export cf_EDGE_TUN=${cf_EDGE_TUN}
            ;;
        a)
            cf_EDGE_IP=${arg_value}
            LOG_INFO "cf_EDGE_IP: '${cf_EDGE_IP}'"
            # export cf_EDGE_IP=${cf_EDGE_IP}
            ;;
        c | community)
            cf_EDGE_COMMUNITY=${arg_value}
            LOG_INFO "cf_EDGE_COMMUNITY: '${cf_EDGE_COMMUNITY}'"
            # export cf_EDGE_COMMUNITY=${cf_EDGE_COMMUNITY}
            ;;
        k)
            cf_EDGE_KEY=${arg_value}
            LOG_INFO "cf_EDGE_KEY: '${cf_EDGE_KEY}'"
            # export cf_EDGE_KEY=${cf_EDGE_KEY}
            ;;
        A[0-9])
            cf_EDGE_ENCRYPTION=${arg}
            LOG_INFO "cf_EDGE_ENCRYPTION: '${cf_EDGE_ENCRYPTION}'"
            # export cf_EDGE_ENCRYPTION=${cf_EDGE_ENCRYPTION}
            ;;
        l | supernode-list)
            cf_SUPERNODE_HOST=${arg_value%:*}
            cf_SUPERNODE_PORT=${arg_value#*:}
            LOG_INFO "cf_SUPERNODE_HOST: '${cf_SUPERNODE_HOST}'"
            LOG_INFO "cf_SUPERNODE_PORT: '${cf_SUPERNODE_PORT}'"
            # export cf_SUPERNODE_HOST=${cf_SUPERNODE_HOST}
            # export cf_SUPERNODE_PORT=${cf_SUPERNODE_PORT}
            ;;
        p)
            cf_SUPERNODE_PORT_V3=${arg_value#*:}
            LOG_INFO "cf_SUPERNODE_PORT_V3: '${cf_SUPERNODE_PORT_V3}'"
            # export cf_SUPERNODE_PORT_V3=${cf_SUPERNODE_PORT_V3}
            ;;
        *)
            cf_N2N_ARGS="${cf_N2N_ARGS} ${arg}"
            LOG_WARNING "cf_N2N_ARGS: '${cf_N2N_ARGS}'"
            # export cf_N2N_ARGS="${cf_N2N_ARGS}"
            ;;
        esac
        LOG_INFO "######"
    done < <(cat ${1} | grep -Ev '^($|#)')
}
