#!/bin/bash

source 0x0_init-logger.sh

set -o errexit
set -o nounset
set -o pipefail

VERSION_B_S_rC=${VERSION_B_S_rC:-}
VERSION_SMALL=${VERSION_SMALL:-}
N2N_DESC_DIR=${N2N_DESC_DIR:-/tmp/desc}

n2n_edge_biggest=$(find ${DOWNLOAD_PATH} -type f | grep edge | grep -v upx | xargs -I {} du -h {} | sort -rh | head -n 1 | awk '{print$2}')
if [[ -z "${n2n_edge_biggest}" ]]; then
    LOG_ERROR_WAIT_EXIT "n2n_edge_biggest 获取失败"
fi
chmod +x ${n2n_edge_biggest}

source 3x0_n2n_fixlib.sh

down_version="$(${n2n_edge_biggest} -h 2>&1 | grep Welcome | grep -Eo 'v\.?[0-9]\.[0-9]\.[0-9]' | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
if [[ -n "${VERSION_B_S_rC}" ]]; then
    define_version="$(echo ${VERSION_B_S_rC} | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
else
    define_version="$(echo ${VERSION_SMALL} | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
fi
if [[ "${define_version}" != "${down_version}" || -z "${down_version}" ]]; then
    LOG_ERROR "下载版本不匹配: ${define_version} != ${down_version}"
    LOG_ERROR "$(${n2n_edge_biggest} -h)"
    # exit 1
fi

n2n_src_dir=${n2n_edge_biggest%/*}
if [[ -z "${n2n_src_dir}" ]]; then
    LOG_ERROR_WAIT_EXIT "n2n_src_dir 获取失败"
fi

mkdir -p "${N2N_DESC_DIR}"
LOG_INFO "n2n_src_dir: ${n2n_src_dir}"
cp -r ${n2n_src_dir}/* ${N2N_DESC_DIR}
chmod +x ${N2N_DESC_DIR}/*

ls -l ${N2N_DESC_DIR}

if [[ ! -f "${N2N_DESC_DIR}/edge" ]]; then
    edge_file_src="$(ls ${N2N_DESC_DIR}/edge* | grep -v upx)"
    if [[ -z "${edge_file_src}" ]]; then
        LOG_ERROR_WAIT_EXIT "复制文件错误: edge_file_src- 为空"
    fi
    LOG_WARNING "使用${edge_file_src}"
    cp -f "${edge_file_src}" "${N2N_DESC_DIR}/edge"
fi
if [[ ! -f "${N2N_DESC_DIR}/supernode" ]]; then
    supernode_file_src="$(ls ${N2N_DESC_DIR}/supernode* | grep -v upx)"
    if [[ -z "${supernode_file_src}" ]]; then
        LOG_ERROR_WAIT_EXIT "复制文件错误: supernode_file_src- 为空"
    fi
    LOG_WARNING "使用${supernode_file_src}"
    cp -f "${supernode_file_src}" "${N2N_DESC_DIR}/supernode"
fi
LOG_RUN ls ${N2N_DESC_DIR}
