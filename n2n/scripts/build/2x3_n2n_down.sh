#!/bin/bash

source 0x0_init-logger.sh
source 2x0_init_kernel_and_machine.sh

set -o errexit
set -o nounset
set -o pipefail

mkdir -p "${DOWNLOAD_PATH}"
# s_download_urls="${STR_DOWNLOAD_URLS}"
# LOG_INFO "s_download_urls: ${s_download_urls}"

# l_download_urls=(${s_download_urls//,/ })
# for download_url in ${l_download_urls[@]}; do
cat /tmp/down_urls.txt | while read download_url
do
    LOG_INFO "download_url: ${download_url}"
    if [ -z "${download_url}" ]; then
        continue
    fi
    dl_filename=${download_url##*/}
    LOG_INFO "dl_filename: ${dl_filename}"
    dl_machine=${dl_filename##*linux_}
    dl_machine=${dl_machine%%_*}
    dl_machine=${dl_machine%%(*}
    LOG_INFO "dl_machine: ${dl_machine}"
    if [[ "${dl_machine}" == "${filename_machine}" ]]; then
        LOG_INFO 开始下载 - ${download_url}
        wget --no-check-certificate -q ${download_url} -O "${DOWNLOAD_PATH}/${dl_filename}"
        if [[ $? != 0 ]]; then
            LOG_ERROR_WAIT_EXIT "下载失败: ${down_url}"
        fi
    fi
done
