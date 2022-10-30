#!/bin/bash

. init_logger.sh
. init_extract.sh
. init_latest_info.sh
. init_kernel_name_and_machine_name.sh

LOG_INFO KERNEL=${KERNEL}
LOG_INFO MACHINE=${MACHINE}
LOG_INFO BIG_VERSION=${BIG_VERSION}
LOG_INFO SMALL_VERSION=${SMALL_VERSION}
LOG_INFO COMMITS=${COMMITS}

INIT_LATEST_INFO

down_dir=''
if [[ "${SMALL_VERSION}" != "${latest_small_version}" ]]; then
    down_dir="/Old/linux_${MACHINE}"
fi
LOG_INFO "down_dir:${down_dir}"

down_path=$(curl -k -sS https://api.github.com/repos/lucktu/n2n/contents/Linux${down_dir}?ref=master | jq '.[]|{path}|..|.path?' | grep linux_${MACHINE:+${MACHINE}_} | grep v${SMALL_VERSION} | sed 's/\"//g')
if [[ -z "${down_path}" ]]; then
    LOG_ERROR "down_path 获取失败"
    exit 1
fi
LOG_INFO "down_path:${down_path}"

down_url="https://github.com/lucktu/n2n/raw/master/${down_path}"

down_dir="/tmp/down"
down_filename="${down_dir}/${down_url##*/}"

LOG_INFO "Try: 下载 - ${down_url}"
mkdir "${down_dir}"
wget --no-check-certificate -q ${down_url} -O "${down_filename}"

if [[ $? != 0 ]]; then
    LOG_ERROR "下载失败: ${down_url}"
    exit 1
fi
