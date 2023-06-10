#!/bin/bash

source 0x0_init-logger.sh
source 2x0_init_kernel_and_machine.sh
source 2x0_init_extract.sh

for src_file in $(find ${DOWNLOAD_PATH} -name "*${filename_machine}*" | grep -vE '(eb)|(mips)'); do
    LOG_INFO "Try: 解压 - ${src_file}"
    EXTRACT_ALL "${src_file}"
done
LOG_WARNING "解压结果：\n$(find ${DOWNLOAD_PATH} -type f | grep edge | grep -v upx | xargs -I {} du -h {} | sort -rh)"
