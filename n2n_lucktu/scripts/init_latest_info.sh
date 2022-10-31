#!/bin/bash
. init_logger.sh

INIT_LATEST_INFO() {
    src_dir="/tmp/n2n/${KERNEL^}"
    if [[ -e "${src_dir}" ]]; then
        latest_path="$(ls ${src_dir} | grep linux_x64 | head -n 1 | sed 's/\"//g')"
    else
        # e.g. Linux/n2n_v3_linux_x64_v3.1.1-16_r1200_all_by_heiye.rar
        latest_path=$(curl -k -sS https://api.github.com/repos/lucktu/n2n/contents/${KERNEL^}?ref=master | jq '.[]|{path}|..|.path?' | grep linux_x64 | head -n 1 | sed 's/\"//g')
    fi
    LOG_INFO "latest_path: ${latest_path}"

    # e.g. n2n_v3_linux_x64_v3.1.1-16_r1200_all_by_heiye.rar
    latest_file=${latest_path##*/}
    LOG_INFO "latest_file: ${latest_file}"

    # e.g. v3
    latest_big_version=${latest_file#*n2n_}
    latest_big_version=${latest_big_version%_linux*}
    LOG_INFO "latest_big_version: ${latest_big_version}"

    # e.g. 3.1.1-16
    latest_small_version=${latest_file##*_v}
    latest_small_version=${latest_small_version%%_r*}
    LOG_INFO "latest_small_version: ${latest_small_version}"

    # e.g. 1200
    latest_commit=${latest_file##*${latest_small_version}}
    latest_commit=${latest_commit##*_r}
    latest_commit=${latest_commit%%.*}
    latest_commit=${latest_commit%%_*}
    LOG_INFO "latest_commit: ${latest_commit}"
}

LOG_INFO "init_latest_info success"
