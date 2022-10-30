#!/bin/bash
. init_logger.sh

INIT_LATEST_INFO() {

    # e.g. Linux/n2n_v3_linux_x64_v3.1.1-16_r1200_all_by_heiye.rar
    latest_path=$(curl -k -sS https://api.github.com/repos/lucktu/n2n/contents/Linux?ref=master | jq '.[]|{path}|..|.path?' | grep linux_x64 | sed 's/\"//g')
    # e.g. n2n_v3_linux_x64_v3.1.1-16_r1200_all_by_heiye.rar
    latest_file=${latest_path##*/}
    # e.g. v3
    latest_big_version=${latest_file#*n2n_}
    latest_big_version=${latest_big_version%_linux*}
    # e.g. 3.1.1-16
    latest_small_version=${latest_file##*_v}
    latest_small_version=${latest_small_version%%_r*}
    # e.g. 1200
    latest_commits=${latest_file##*${latest_small_version}}
    latest_commits=${latest_commits##*_r}
    latest_commits=${latest_commits%%.*}
    latest_commits=${latest_commits%%_*}

    LOG_INFO latest_path=${latest_path}
    LOG_INFO latest_file=${latest_file}
    LOG_INFO latest_big_version=${latest_big_version}
    LOG_INFO latest_small_version=${latest_small_version}
    LOG_INFO latest_commits=${latest_commits}
}

LOG_INFO "init_latest_info success"