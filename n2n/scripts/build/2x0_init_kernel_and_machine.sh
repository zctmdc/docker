#!/bin/bash

source 0x0_init-logger.sh

set -o errexit
set -o nounset
set -o pipefail

SEL_PLATFORM() {
    sel_machine=${1:-}
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


### 自动识别系统类型
sel_os() {
    uos=$(uname -s | tr '[A-Z]' '[a-z]')
    case $uos in
    *linux*)
        myos="linux"
        ;;
    *)
        LOG_ERROR_WAIT_EXIT "识别失败的系统 - $uos"
        ;;
    esac
    LOG_INFO "识别成功的系统 - $myos"
}

### 自动识别CPU架构
sel_cpu() {
    ucpu=$(uname -m | tr '[A-Z]' '[a-z]')
    case $ucpu in
    *i386* | *i486* | *i586* | *i686* | *bepc* | *i86pc*)
        mycpu="i386"
        ;;
    *amd*64* | *x86-64* | *x86_64*)
        case $(getconf LONG_BIT) in
        64)
            mycpu="amd64"
            ;;
        32)
            mycpu="i386"
            ;;
        esac
        ;;

    *armv6l*)
        mycpu="arm/v6"
        ;;
    *armv7l*)
        mycpu="arm/v7"
        ;;
    *aarch64*)
        mycpu="aarch64"
        ;;
    *mips*)
        case $ucpu in
        mips | mipsel | mips64 | mips64el)
            mycpu=$ucpu
            ;;
        *)
            LOG_ERROR_WAIT_EXIT "分析失败的CPU架构类型 - 未知的 MIPS : $ucpu"
            ;;
        esac
        ;;
    *)
        LOG_ERROR_WAIT_EXIT "分析失败的CPU架构类型 - $ucpu"
        ;;
    esac
    LOG_INFO "分析成功的CPU架构类型 - $mycpu"
}
myos=""
mycpu=""
sel_os
sel_cpu
MY_KERNEL=${MY_KERNEL:-}
if [[ -z ${MY_KERNEL} ]]; then
    case ${myos} in
    linux)
        MY_KERNEL="linux"
        ;;
    *)
        LOG_ERROR_WAIT_EXIT "不支持的系统 - ${myos}"
        ;;
    esac
    LOG_INFO "受支持的系统 - ${myos} -> ${MY_KERNEL}"
fi

MY_MACHINE=${MY_MACHINE:-}
if [[ -z ${MY_MACHINE} ]]; then
    case ${mycpu} in
    i386)
        MY_MACHINE="x86"
        ;;
    amd64)
        MY_MACHINE="x64"
        ;;
    arm | arm/v6 | arm/v7)
        MY_MACHINE="arm"
        ;;
    arm64 | aarch64)
        MY_MACHINE="arm64"
        ;;
    armeb | mips | mips64 | mips64el | mipsel)
        MY_MACHINE=$mycpu
        ;;
    *)
        LOG_ERROR_WAIT_EXIT "不支持的CPU架构类型 - ${mycpu}"
        ;;
    esac
    LOG_INFO "受支持的CPU架构类型 - ${mycpu} -> ${MY_MACHINE}"
fi

SEL_PLATFORM $MY_MACHINE
