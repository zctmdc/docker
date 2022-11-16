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
        EDGE_TUN=${arg_value}
        ;;
    a)
        EDGE_IP=${arg_value}
        ;;
    c)
        EDGE_COMMUNITY=${arg_value}
        ;;
    k)
        EDGE_KEY=${arg_value}
        ;;
    A[0-9])
        EDGE_ENCRYPTION=${arg}
        ;;
    l)
        SUPERNODE_HOST=${arg_value%:*}
        SUPERNODE_PORT=${arg_value#*:}
        ;;
    p)
        SUPERNODE_PORT_V3=${arg_value}
        ;;
    *)
        N2N_ARGS="${N2N_ARGS} ${arg}"
        ;;
    esac
    LOG_INFO "######"
done
