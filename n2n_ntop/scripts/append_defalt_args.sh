#!/bin/bash

# set -x
. init_logger.sh

if [[ "${MODE}" == "SUPERNODE" ]]; then
    case "${VERSION_B_S_rC%%_*}" in
    "v1")
        N2N_ARGS="${N2N_ARGS}"
        ;;
    "v2")
        N2N_ARGS="${N2N_ARGS}  -f"
        echo "append_defalt_args: -f"
        ;;
    "v2s")
        N2N_ARGS="${N2N_ARGS}  -f"
        echo "append_defalt_args: -f"
        ;;
    "v3")
        N2N_ARGS="${N2N_ARGS}  -F ${EDGE_TUN} -f -M"
        echo "append_defalt_args: -F ${EDGE_TUN} -f -M"
        ;;
    esac
elif [[ "$(echo ${MODE} | grep -E '^(DHCPD)|(DHCPC)|(STATIC)$')" ]]; then
    case "${VERSION_B_S_rC%%_*}" in
    "v1")
        N2N_ARGS="${N2N_ARGS} -br"
        echo "append_defalt_args:  -br"
        ;;
    "v2")
        N2N_ARGS="${N2N_ARGS} -Efr"
        echo "append_defalt_args:  -Efr"
        ;;
    "v2s")
        N2N_ARGS="${N2N_ARGS} -L auto -bfr"
        echo "append_defalt_args:  -L auto -bfr"
        ;;
    "v3")
        N2N_ARGS="${N2N_ARGS} -e auto -I ${EDGE_TUN} -Efr "
        echo "append_defalt_args: -e auto -I ${EDGE_TUN} -Efr"
        ;;
    esac
fi
