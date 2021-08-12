#!/bin/bash
. init_logger.sh
. init_kernel_name_and_machine_name.sh

if [[ -z ${KERNEL} ]]; then
    case ${myos} in
    linux)
        LOG_INFO "受支持的系统 - ${myos}"
        KERNEL="linux"
        ;;
    macosx)
        KERNEL="darwin"
        LOG_INFO "受支持的系统 - ${myos}"
        ;;
    windows)
        LOG_INFO "受支持的系统 - ${myos}"
        KERNEL="windows"
        ;;
    *)
        LOG_ERROR "不支持的系统 - ${myos}"
        exit 1
        ;;
    esac

fi
if [[ -z ${MACHINE} ]]; then
    case ${mycpu} in
    i386)
        LOG_INFO "受支持的CPU架构类型 - ${mycpu}"
        MACHINE="x86"
        ;;
    amd64)
        LOG_INFO "受支持的CPU架构类型 - ${mycpu}"
        MACHINE="x64"
        ;;
    arm)
        LOG_INFO "受支持的CPU架构类型 - ${mycpu}"
        MACHINE="arm"
        ;;
    arm64)
        LOG_INFO "受支持的CPU架构类型 - ${mycpu}"
        MACHINE="arm64(aarch64)"
        ;;
    mips | mips64 | mips64el | mipsel | amd64)
        LOG_INFO "受支持的CPU架构类型 - ${mycpu}"
        MACHINE=$mycpu
        ;;
    *)
        LOG_ERROR "不支持的CPU架构类型 - ${mycpu}"
        exit 1
        ;;
    esac
fi

FILE_NAME=$(
    curl -k -sS https://github.com/lucktu/n2n/tree/master/$(echo ${KERNEL} | sed -e 's/\b\(.\)/\u\1/g') |
        grep -oP "(?<=\")n2n_v3_${KERNEL}_$(echo $MACHINE | sed 's/(/\\(/' | sed 's/)/\\)/')_.*?zip"
)
echo ${FILE_NAME}
if [[ -z ${FILE_NAME} ]]; then
    LOG_ERROR "错误的文件名 - ${FILE_NAME}"
    LOG_ERROR "检查相关变量 - KERNEL:${KERNEL}, MACHINE:${MACHINE}"
    exit 1
fi
wget --no-check-certificate -qO "/tmp/n2n.zip" "https://raw.githubusercontent.com/lucktu/n2n/master/$(echo ${KERNEL} | sed -e 's/\b\(.\)/\u\1/g')/${FILE_NAME}"

unzip -o -d /tmp/n2n/ "/tmp/n2n.zip"
if [[ -d "/tmp/n2n/static" ]]; then
    cp -r /tmp/n2n/static/* /tmp/n2n/
fi

ls -l /tmp/n2n