#!/bin/bash
source init_logger.sh
source init_kernel_name_and_machine_name.sh

if [[ -z ${KERNEL} ]]; then
  myos=""
  zctmdc_sel_os
  case $myos in
  linux | freebsd | darwin | windows)
    LOG_INFO "受支持的系统 - $myos"
    ;;
  *)
    LOG_ERROR "不支持的系统 - $myos"
    exit 1
    ;;
  esac
  KERNEL="$myos"
fi
if [[ -z ${MACHINE} ]]; then
  mycpu=""
  zctmdc_sel_cpu
  case $mycpu in
  i386)
    mycpu=386
    LOG_INFO "受支持的CPU架构类型 - $mycpu"
    ;;
  arm | arm64 | mips | mips64 | mips64el | mipsel | amd64)
    LOG_INFO "受支持的CPU架构类型 - $mycpu"
    ;;
  *)
    LOG_ERROR "不支持的CPU架构类型 - $mycpu"
    exit 1
    ;;
  esac
  MACHINE=$mycpu
fi

if [[ -z ${FRP_VERSION} ]]; then
  LOG_INFO "正在从GITHUB获取版本"
  FRP_VERSION=$(
    curl -sS https://github.com/fatedier/frp/releases/latest |
      grep -oP "(\d+\.){2}\d+" |
      head -n 1
  )
  LOG_INFO "FRP_VERSION : GITHUB - $FRP_VERSION"
fi

if [[ -z ${FRP_VERSION} ]]; then
  LOG_INFO "正在从七牛云获取版本"
  FRP_VERSION=$(curl -sS http://rt.qiniu.zctmdc.cn/bin/frp_version.txt)
  LOG_INFO "FRP_VERSION : 七牛云 - $FRP_VERSION"
fi

FILE_NAME="frp_${FRP_VERSION}_${KERNEL}_${MACHINE}.tar.gz"
wget -O ${FILE_NAME} https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE_NAME}

tar -zxvf ${FILE_NAME}

mv frp_${FRP_VERSION}_${KERNEL}_${MACHINE} /tmp/frp

ls -l /tmp/frp
