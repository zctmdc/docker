#!/bin/bash

# set -x
. init_logger.sh
. init_version.sh

CONF_SAVE() {
  conf_file_env="${1}"
  if [[ -z "${conf_file_env}" ]]; then
    LOG_ERROR_WAIT_EXIT "错误: CONF_SAVE: PATH \${1} - 为空 - ${conf_file_env}"
  fi
  touch ${conf_file_env}
  if [[ "${MODE^^}" == "SUPERNODE" ]]; then
    INIT_VERSION
    if [[  "${small_version//./}" -ge 290 ]]; then
      # v.2.9.0+  使用 -p
      LOG_INFO "v3: ${small_version} " 
      ARG_SUPERNODE_PORT="-p ${SUPERNODE_PORT}"
    else
      LOG_INFO "small_version: ${small_version} " 
      ARG_SUPERNODE_PORT="-l ${SUPERNODE_PORT}"
    fi
  elif [[ -n "$(echo ${MODE^^} | grep -E '^(DHCPC)|(DHCPD)|(STATIC)')" ]]; then
    if [[ -n "${EDGE_TUN}" ]]; then
      echo "-d=${EDGE_TUN}" >>${conf_file_env}
    fi

    if [[ -n "${EDGE_IP}" ]]; then
      echo "-a=${EDGE_IP}" >>${conf_file_env}
    fi

    if [[ -n "${EDGE_COMMUNITY}" ]]; then
      echo "-c=${EDGE_COMMUNITY}" >>${conf_file_env}
    fi

    if [[ -n "${EDGE_KEY}" && "${EDGE_ENCRYPTION}" != "-A1" ]]; then
      echo "-k=${EDGE_KEY}" >>${conf_file_env}
      echo "${EDGE_ENCRYPTION}" >>${conf_file_env}
    fi

    if [[ -n "${EDGE_KEY}" ]]; then
      echo "-k=${EDGE_KEY}" >>${conf_file_env}
    fi

    if [[ -n "${SUPERNODE_HOST}" && -n "${SUPERNODE_PORT}" ]]; then
      echo "-l=${SUPERNODE_HOST}:${SUPERNODE_PORT}" >>${conf_file_env}
    fi
  fi
  if [[ -n "${N2N_ARGS}" ]]; then
    echo "${N2N_ARGS}" >>${conf_file_env}
  fi
}
