#!/bin/bash

source 0x0_init-logger.sh

set -o errexit
set -o nounset
set -o pipefail

SEL_PLATFORM() {
    sel_machine=$1
    platform=''
    filename_machine=''

    if [[ -z "${sel_machine}" ]]; then
        LOG_ERROR_WAIT_EXIT "错误: SEL_PLATFORM - sel_machine - 为空"
    fi

    case ${sel_machine} in
    x64 | amd64)
        filename_machine="x64"
        platform="linux/amd64"
        ;;
    x86 | 386)
        filename_machine="x86"
        platform="linux/386"
        ;;
    arm64 | aarch64 | arm64/v8)
        filename_machine="arm64"
        platform="linux/arm64/v8"
        ;;
    arm | arm/v7)
        filename_machine="arm"
        platform="linux/arm/v7"
        ;;
    arm/v6)
        filename_machine="arm"
        platform="linux/arm/v6"
        ;;
    arm64eb | aarch64eb)
        LOG_ERROR "未支持的CPU架构类型 - ${sel_machine}"
        filename_machine="arm64eb"
        platform=${sel_machine}
        ;;
    *)
        LOG_ERROR "不支持的CPU架构类型 - ${sel_machine}"
        filename_machine=${sel_machine}
        platform=${sel_machine}
        ;;
    esac

    LOG_INFO "filename_machine: ${filename_machine}, platform: ${platform}"
}
