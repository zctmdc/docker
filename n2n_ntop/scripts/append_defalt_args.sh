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
        ;;
    "v2s")
        N2N_ARGS="${N2N_ARGS}  -f"
        ;;
    "v3")
        N2N_ARGS="${N2N_ARGS}  -F ${EDGE_TUN} -f -M"
        ;;
    esac
elif [[ "$(echo ${MODE} | grep -E '^(DHCPD)|(DHCPC)|(STATIC)$')" ]]; then
    case "${VERSION_B_S_rC%%_*}" in
    "v1")
        N2N_ARGS="${N2N_ARGS} -br"
        ;;
    "v2")
        N2N_ARGS="${N2N_ARGS} -EfrA"
        ;;
    "v2s")
        N2N_ARGS="${N2N_ARGS} -L auto -bfr "
        ;;
    "v3")
        N2N_ARGS="${N2N_ARGS} -e auto -I ${EDGE_TUN} -Efr "
        ;;
    esac
fi
