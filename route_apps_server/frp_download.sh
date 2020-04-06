#!/bin/bash
set -x
if [[ -s ${1} ]]; then
  FORCE_UPDATE=${1}
fi
if [[ ! -s ${FRP_TMP_DIR} ]]; then
  FRP_TMP_DIR=/tmp/frp
fi
if [[ ! -s ${1} ]]; then
  FRP_OPT_DIR=/tmp/bin
fi

mkdir -p ${FRP_TMP_DIR}
mkdir -p ${FRP_OPT_DIR}
cd ${FRP_TMP_DIR}/
frp_version=$(
  curl -s https://github.com/fatedier/frp/releases/latest |
    grep -Eo "[0-9]+\.[0-9]+\.[0-9]+"
)
version_file=${FRP_OPT_DIR}/frp_version.txt
if [[ "${FORCE_UPDATE}"="FALSE" && -e "${version_file}" && "$(cat ${version_file})"="${frp_version}" ]]; then
  echo "FRP - 已为最新版本"
  return
fi
echo "FRP - 发现新版本,即将更新"
rm -rf FRP_TMP_DIR FRP_OPT_DIR
curl -s https://github.com/fatedier/frp/releases/tag/v${frp_version} |
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
    wget https://github.com/fatedier/frp/releases/download/v${frp_version}/${file_name} \
      -O ${FRP_TMP_DIR}/${file_name}
    case $file_suffix in
    tar.gz)
      tar -zxvf ${FRP_TMP_DIR}/${file_name}
      ;;
    zip)
      unzip ${FRP_TMP_DIR}/${file_name}
      ;;
    *)
      echo "未知文件 - ${file_name}"
      ;;
    esac
    for frp_taction in frpc frps; do
      frp_taction_file="${FRP_TMP_DIR}/frp_${frp_version}_${kernel_name}_${machine}/${frp_taction}"
      if [[ -f "${frp_taction_file}" ]]; then
        cp -f "${frp_taction_file}" "${FRP_OPT_DIR}/${frp_taction}_${kernel_name}_${machine}"
        chmod a+x "${FRP_OPT_DIR}/${frp_taction}_${kernel_name}_${machine}"
      elif [[ -f "${frp_taction_file}.exe" ]]; then
        cp -f "${frp_taction_file}.exe" "${FRP_OPT_DIR}/${frp_taction}_${kernel_name}_${machine}.exe"
      else
        echo "${frp_taction_file} - 不存在 - No such file"
      fi
    done
    # rm -rf frp_${frp_version}_${kernel_name}_${machine}*
    echo ----------------------------------------------------------------
  done &&
  echo $frp_version >${version_file}
