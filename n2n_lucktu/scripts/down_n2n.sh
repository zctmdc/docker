#!/bin/bash

. init_logger.sh
. init_extract.sh
. init_latest_info.sh
. init_kernel_name_and_machine_name.sh

LOG_INFO "KERNEL: ${KERNEL}"
LOG_INFO "MACHINE: ${MACHINE}"
LOG_INFO "BIG_VERSION: ${BIG_VERSION}"
LOG_INFO "SMALL_VERSION: ${SMALL_VERSION}"
LOG_INFO "COMMIT: ${COMMIT}"
for fn_platform in "x64" "x86" "arm64(aarch64)" "arm"; do
    # 遍历可能存在的文件夹进行匹配
    for down_dir in "" "/Old/linux_${MACHINE}" "n2n_${BIG_VERSION}"; do
        down_path=$(curl -k -sS https://api.github.com/repos/lucktu/n2n/contents/${MACHINE^}${down_dir}?ref=master | jq '.[]|{path}|..|.path?' | grep linux_${MACHINE:+${MACHINE}_} | grep ${BIG_VERSION} | grep ${SMALL_VERSION} | grep ${COMMIT} | sed 's/\"//g')
        if [[ -z "${down_path}" ]]; then
            LOG_WARNING "down_path 获取失败 - ${down_dir}"
            continue
        fi
        LOG_INFO "use down_dir: ${down_dir}"
        break
    done
    if [[ -z "${down_path}" ]]; then
        LOG_INFO "find ${down_path}"
    fi
done
if [[ -z "${down_path}" ]]; then
    LOG_ERROR "down_path 获取失败"
    exit 1
fi
LOG_INFO "down_path: ${down_path}"
# e.g. https://github.com/lucktu/n2n/raw/master/Linux/n2n_v3_linux_x64_v3.1.1-16_r1200_all_by_heiye.rar
down_url="https://github.com/lucktu/n2n/raw/master/${down_path}"

down_dir="/tmp/down"
# e.g. n2n_v3_linux_x64_v3.1.1-16_r1200_all_by_heiye.rar
down_filename="${down_dir}/${down_url##*/}"

LOG_INFO "Try: 下载 - ${down_url}"
mkdir "${down_dir}"
wget --no-check-certificate -q ${down_url} -O "${down_filename}"

if [[ $? != 0 ]]; then
    LOG_ERROR "下载失败: ${down_url}"
    exit 1
fi
