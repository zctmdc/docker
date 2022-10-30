down_dir="/tmp/down"
LOG_INFO "Try: 解压 - ${down_dir}"
EXTRACT_ALL "${down_dir}"

LOG_WARNING "解压结果：\n$(find ${down_dir} -type f | grep edge | grep -v upx | xargs -I {} du -h {} | sort -rh)"
