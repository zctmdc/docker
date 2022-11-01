#!/bin/bash

. init_logger.sh
src_dir="/tmp/n2n/${KERNEL^}"
if [[ -e "${src_dir}" ]]; then
    . copy_n2n.sh
else
    . down_n2n.sh
fi
. extract_n2n.sh
. sel_n2n.sh
