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

# 遍历可能存在的文件夹进行匹配
src_dir='/tmp/n2n'
for down_dir in "" "/Old/linux_${dn_machine}" "/n2n_${BIG_VERSION}"; do
    if [[ "${down_dir}" == "/n2n_v3" ]]; then
        continue
    fi
    api_url="${src_dir}${down_dir}"
    LOG_INFO "api_url: ${api_url}"
    resp="$(ls ${api_url})"
    LOG_INFO "resp: ${resp}"
    down_path=$(echo "${resp}" | grep ${KERNEL}_${fn_machine}_ | grep ${BIG_VERSION} | grep ${SMALL_VERSION} | grep ${COMMIT} | sed 's/\"//g')
    if [[ -z "${down_path}" ]]; then
        LOG_WARNING "down_path 获取失败 - ${down_dir} - ${src_dir} - ${result}"
        continue
    fi
    LOG_INFO "use down_dir: ${down_dir}"
    break
done
if [[ -z "${down_path}" ]]; then
    LOG_INFO "find ${down_path}"
fi
if [[ -z "${down_path}" ]]; then
    LOG_ERROR "down_path 获取失败"
    exit 1
fi
LOG_INFO "down_path: ${down_path}"
# e.g. /tmp/n2n/Linux/n2n_v3_linux_x64_v3.1.1-16_r1200_all_by_heiye.rar
down_url="${src_dir}${down_path}"

down_dir="/tmp/down"
# e.g. n2n_v3_linux_x64_v3.1.1-16_r1200_all_by_heiye.rar
down_filename="${down_dir}/${down_url##*/}"

LOG_INFO "Try: 复制 - ${down_url}"
mkdir "${down_dir}"
cp ${down_url} "${down_filename}"
if [[ $? != 0 ]]; then
    LOG_ERROR "复制失败: ${down_url}"
    exit 1
fi
