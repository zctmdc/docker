#!/bin/bash
# set -x

mkdir -p ${FRP_TMP_DIR} ${FRP_OPT_DIR}
cd ${FRP_TMP_DIR}/
frp_version=$(
  curl -k -sS https://github.com/fatedier/frp/releases/latest |
    grep -oP "(\d+\.){2}\d+" |
    head -n 1
)
version_file=${FRP_OPT_DIR}/frp_version.txt
if [[ "${FORCE_UPDATE}"="FALSE" && -e "${version_file}" && "$(cat ${version_file})" == "${frp_version}" ]]; then
  echo "FRP - 已为最新版本"
  exit
fi
echo "FRP - 发现新版本,即将更新"
rm -rf ${FRP_TMP_DIR}/* ${FRP_OPT_DIR}/frp* ${version_file}

replaseKV='
el-le
amd64-x64
386-x86
i386-x86
'

curl -k -sS https://github.com/fatedier/frp/releases/tag/v${frp_version} |
  grep v${frp_version} |
  grep -Eo "frp_.+(gz|zip)" |
  while read line; do
    echo "$line"
    file_name=$line
    kernel_name_and_machine_and_suffix=$(echo $file_name | sed "s/frp_${frp_version}_//g")
    file_suffix=${kernel_name_and_machine_and_suffix#*.}
    kernel_name_and_machine=${kernel_name_and_machine_and_suffix%%.*}
    kernel_name=${kernel_name_and_machine%_*}
    machine=${kernel_name_and_machine#*_}
    wget --no-check-certificate -qO ${FRP_TMP_DIR}/${file_name} \
      https://github.com/fatedier/frp/releases/download/v${frp_version}/${file_name}

    case $file_suffix in
    tar.gz)
      tar -zxvf ${FRP_TMP_DIR}/${file_name}
      ;;
    zip)
      unzip -o ${FRP_TMP_DIR}/${file_name}
      ;;
    *)
      echo "未知文件 - ${file_name}"
      ;;
    esac
    for frp_action in frpc frps; do
      frp_src_file="${FRP_TMP_DIR}/frp_${frp_version}_${kernel_name}_${machine}/${frp_action}"
      frp_to_file="${FRP_OPT_DIR}/${frp_action}_${kernel_name}_${machine}"
      if [[ -f "${frp_src_file}" ]]; then
        chmod 0755 "${frp_src_file}" && cp "${frp_src_file}" "${frp_to_file}"
        for line_rep in ${replaseKV}; do
          line_rep_k="${line_rep%-*}"
          line_rep_v="${line_rep#*-}"
          if [[ "${frp_to_file}" == *"${line_rep_k}" ]]; then
            frp_to_file="${frp_to_file%%${line_rep_k}}${line_rep_v}"
            cp -f "${frp_src_file}" "${frp_to_file}"
          fi
          if [[ "${frp_to_file}" == *"${line_rep_v}" ]]; then
            frp_to_file="${frp_to_file%%${line_rep_v}}${line_rep_k}"
            cp -f "${frp_src_file}" "${frp_to_file}"
          fi
        done
      elif [[ -f "${frp_src_file}.exe" ]]; then
        cp -f "${frp_src_file}.exe" "${frp_to_file}.exe"
      else
        echo "${frp_src_file} - 不存在 - No such file"
      fi
    done
    # rm -rf frp_${frp_version}_${kernel_name}_${machine}*
    echo ----------------------------------------------------------------
  done &&
  echo ################################################################
echo "frp_version : v${frp_version}" &&
  echo ${frp_version} >${version_file}
