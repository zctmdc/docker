#!/bin/bash

# set -x
. init_logger.sh

conf_file="$1"
for arg in $(cat ${conf_file} | grep -Ev '^($|#)'); do
    LOG_INFO "arg=${arg}"
    arg_key="${arg%%=*}"
    arg_key="${arg_key#-}"
    arg_value="${arg#*${arg_key}}"
    arg_value="${arg_value#=}"
    LOG_INFO "arg_key=${arg_key}"
    LOG_INFO "arg_value=${arg_value}"
    LOG_INFO "----"
    case "${arg_key}" in
    d)
        cf_EDGE_TUN=${arg_value}
        ;;
    a)
        cf_EDGE_IP=${arg_value}
        ;;
    c)
        cf_EDGE_COMMUNITY=${arg_value}
        ;;
    k)
        cf_EDGE_KEY=${arg_value}
        ;;
    A[0-9])
        cf_EDGE_ENCRYPTION=${arg}
        ;;
    l)
        cf_SUPERNODE_HOST=${arg_value%:*}
        cf_SUPERNODE_PORT=${arg_value#*:}
        ;;
    p)
        cf_SUPERNODE_PORT_V3=${arg_value}
        ;;
    *)
        cf_N2N_ARGS="${N2N_ARGS} ${arg}"
        ;;
    esac
    LOG_INFO "######"
done
