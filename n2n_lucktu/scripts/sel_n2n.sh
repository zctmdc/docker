#!/bin/bash
. init_logger.sh

n2n_edge_biggest=$(find ${down_dir} -type f | grep edge | grep -v upx | xargs -I {} du -h {} | sort -rh | head -n 1 | awk '{print$2}')
if [[ -z "${n2n_edge_biggest}" ]]; then
    LOG_ERROR "n2n_edge_biggest 获取失败"
    exit 1
fi

down_version="$(${n2n_edge_biggest} -h | grep Welcome | grep -Eo 'v\.[0-9]\.[0-9]\.[0-9]' | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
define_version="$(echo ${SMALL_VERSION} | grep -Eo '[0-9]\.[0-9]\.[0-9]')"
if [[ "${define_version}" != "${down_version}" || -z "${down_version}" ]]; then
    LOG_ERROR "下载版本不匹配: ${define_version} != ${down_version}"
    exit 1
fi


n2n_src_dir=${n2n_edge_biggest%/*}
if [[ -z "${n2n_src_dir}" ]]; then
    LOG_ERROR "n2n_src_dir 获取失败"
    exit 1
fi

n2n_desc_dir="/tmp/desc"
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
