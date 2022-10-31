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
for down_dir in "" "/Old/linux_${dn_machine}" "/n2n_${BIG_VERSION}"; do
    if [[ "${down_dir}" == "/n2n_v3" ]]; then
        continue
    fi
    api_url=https://api.github.com/repos/lucktu/n2n/contents/${KERNEL^}${down_dir}?ref=master
    LOG_INFO "api_url: ${api_url}"
    resp="$(curl -k -sS ${api_url})"
    if [[ ! -z $(echo "$resp" || jq '.message') && -z $(echo "${resp}" | jq '.[]|{path}') ]]; then
        LOG_ERROR "resp: $resp"
        exit 1
    fi
    result=$(echo "${resp}" | jq '.[]|{path}|..|.path?')
    down_path=$(echo "${result}" | grep ${KERNEL}_${fn_machine}_ | grep ${BIG_VERSION} | grep ${SMALL_VERSION} | grep ${COMMIT} | head -n 1 | sed 's/\"//g')
    if [[ -z "${down_path}" ]]; then
        LOG_WARNING "down_path 获取失败 - ${down_dir} - ${api_url}"
        LOG_WARNING "${KERNEL}_${fn_machine}_ ${BIG_VERSION} v.${SMALL_VERSION} ${COMMIT}"
        LOG_ERROR "resp: $resp"
        LOG_ERROR "path[] : $(echo ${resp} | jq '.[]|{path}')"
        LOG_ERROR "path|..: $(echo ${resp} | jq '.[]|{path}|..')"
        LOG_ERROR ".path  : $(echo ${resp} | jq '.[]|{path}|..|.path?')"
        LOG_ERROR "result : $result"
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
# e.g. https://github.com/lucktu/n2n/raw/master/Linux/n2n_v3_linux_x64_v3.1.1-16_r1200_all_by_heiye.rar
down_url="https://github.com/lucktu/n2n/raw/master/${down_path}"

down_dir_desc="/tmp/down"
# e.g. n2n_v3_linux_x64_v3.1.1-16_r1200_all_by_heiye.rar
down_filename="${down_dir_desc}/${down_url##*/}"

LOG_INFO "Try: 下载 - ${down_url} - ${down_filename}"
mkdir "${down_dir_desc}"
wget --no-check-certificate -q ${down_url} -O "${down_filename}"

if [[ $? != 0 ]]; then
    LOG_ERROR "下载失败: ${down_url}"
    exit 1
fi
