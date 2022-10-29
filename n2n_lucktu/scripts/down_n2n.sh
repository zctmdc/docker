#!/bin/bash

. init_logger.sh
. init_extract.sh
. init_latest_info.sh

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

down_path=$(curl https://api.github.com/repos/lucktu/n2n/contents/Linux${down_dir}?ref=master | jq '.[]|{path}|..|.path?' | grep linux_${MACHINE}_ | grep v${SMALL_VERSION} | sed 's/\"//g')
if [[ -z "${down_path}" ]]; then
    LOG_ERROR "down_path 获取失败"
    exit 1
fi
LOG_INFO "down_path:${down_path}"

down_url="https://github.com/lucktu/n2n/raw/master/${down_path}"

down_dir="/tmp/down"
down_filename="${down_dir}/${down_path##*/}"

LOG_INFO "Try: 下载 - ${down_url}"
mkdir "${down_dir}"
wget -q ${down_url} -O "${down_filename}"

LOG_INFO "Try: 解压 - ${down_filename}"
EXTRACT_ALL "${down_filename}"

LOG_WARNING "解压结果：\n$(find ${down_dir} -type f | grep edge | grep -v upx | xargs -I {} du -h {} | sort -rh)"
sleep 10
n2n_file_biggest=$(find ${down_dir} -type f | grep edge | grep -v upx | xargs -I {} du -h {} | sort -rh | head -n 1 | awk '{print$2}')
n2n_src_dir=${n2n_file_biggest%/*}
if [[ -z "${n2n_src_dir}" ]]; then
    LOG_ERROR "n2n_src_dir 获取失败"
    exit 1
fi
n2n_desc_dir="/tmp/n2n"
mkdir -p "${n2n_desc_dir}"
LOG_INFO "n2n_src_dir: ${n2n_src_dir}"
cp -r ${n2n_src_dir}/* ${n2n_desc_dir}
chmod +x ${n2n_desc_dir}/*

ls -l ${n2n_desc_dir}

if [[ ! -f "${n2n_desc_dir}/edge" && -f "${n2n_desc_dir}/edge2s" ]]; then
    LOG_WARNING "使用${n2n_desc_dir}/edge2s"
    cp "${n2n_desc_dir}/edge2s" "${n2n_desc_dir}/edge"
fi
if [[ ! -f "${n2n_desc_dir}/supernode" && -f "${n2n_desc_dir}/supernode2s" ]]; then
    LOG_WARNING "使用${n2n_desc_dir}/supernode2s"
    cp "${n2n_desc_dir}/supernode2s" "${n2n_desc_dir}/supernode"
fi

if [[ ! -f "${n2n_desc_dir}/edge" ]]; then
    edge_file_src="$(ls ${n2n_desc_dir}/edge* | grep -v upx)"
    if [[ -z "${edge_file_src}" ]]; then
        LOG_ERROR "复制文件错误: edge_file_src- 为空"
        exit 1
    fi
    LOG_WARNING "使用${edge_file_src}"
    cp "${edge_file_src}" "${n2n_desc_dir}/edge"
fi
if [[ ! -f "${n2n_desc_dir}/supernode" ]]; then
    supernode_file_src="$(ls ${n2n_desc_dir}/supernode* | grep -v upx)"
    if [[ -z "${supernode_file_src}" ]]; then
        LOG_ERROR "复制文件错误: supernode_file_src- 为空"
        exit 1
    fi
    LOG_WARNING "使用${supernode_file_src}"
    cp "${supernode_file_src}" "${n2n_desc_dir}/supernode"
fi

down_version="$(${n2n_desc_dir}/supernode -h | grep Welcome | grep -Eo 'v\.[0-9]\.[0-9]\.[0-9]' | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
define_version="$(echo ${SMALL_VERSION} | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
if [[ "${define_version}" != "${down_version}" || -z "${down_version}" ]]; then
    LOG_ERROR "下载版本不匹配: ${define_version} != ${down_version}"
    exit 1
fi
