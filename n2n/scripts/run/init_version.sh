#!/bin/bash

# set -x
. init_logger.sh

INIT_VERSION() {
    small_version="$(edge -h | grep Welcome | grep -Eo 'v\.?[0-9]\.[0-9]\.[0-9]' | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
    if [[ -n "${small_version}" ]]; then
        LOG_INFO "small_version: ${small_version}"
        return
    fi
    version_b_s_rc=${VERSION_B_S_rC}
    if [[ -z "${version_b_s_rc}" ]]; then
        LOG_ERROR "错误: SCAN_ONE_BUILD - version_b_s_rc - 为空"
        return
    fi
    small_version="$(echo "${version_b_s_rc}" | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
    LOG_INFO "small_version: ${small_version}"
}
