#!/bin/bash
. init_logger.sh
. init_kernel_name_and_machine_name.sh

if [[ -z ${KERNEL} ]]; then
    case ${myos} in
    linux)
        KERNEL="linux"
        ;;
    macosx)
        KERNEL="darwin"
        ;;
    windows)
        KERNEL="windows"
        ;;
    *)
        LOG_ERROR "不支持的系统 - ${myos}"
        exit 1
        ;;
    esac
    LOG_INFO "受支持的系统 - ${myos} -> ${KERNEL}"
fi

if [[ -z ${MACHINE} ]]; then
    case ${mycpu} in
    i386)
        MACHINE="x86"
        ;;
    amd64)
        MACHINE="x64"
        ;;
    arm)
        MACHINE="arm"
        ;;
    arm64)
        MACHINE="arm64(aarch64)"
        ;;
    mips | mips64 | mips64el | mipsel | amd64)

        MACHINE=$mycpu
        ;;
    *)
        LOG_ERROR "不支持的CPU架构类型 - ${mycpu}"
        exit 1
        ;;
    esac
    LOG_INFO "受支持的CPU架构类型 - ${mycpu} -> ${MACHINE}"
fi

VERSION="_$VERSION"
case $(tr '[A-Z]' '[a-z]' <<<${VERSION##*_}) in
v1)
    SRC_DIR=n2n_v1
    N2N_VERSION=v1
    ;;
v2)
    SRC_DIR=n2n_v2
    N2N_VERSION=v2
    ;;
v2s)
    SRC_DIR=n2n_v2s
    N2N_VERSION=v2s
    ;;
*)
    SRC_DIR=""
    N2N_VERSION=v3
    ;;
esac

LOG_INFO "N2N_VERSION - ${VERSION#*_} -> ${SRC_DIR:+$SRC_DIR:}${N2N_VERSION}"

FILE_NAME=$(
    curl -k -sS https://github.com/lucktu/n2n/tree/master/$(echo ${KERNEL} | sed -e 's/\b\(.\)/\u\1/g')${SRC_DIR:+/$SRC_DIR} |
        grep -oP "(?<=\")n2n_${N2N_VERSION}_${KERNEL}_$(echo $MACHINE | sed 's/(/\\(/' | sed 's/)/\\)/')_.*?zip"
)
echo ${FILE_NAME}

if [[ -z ${FILE_NAME} ]]; then
    LOG_ERROR "错误的文件名 - ${FILE_NAME}"
    LOG_ERROR "检查相关变量 - KERNEL:${KERNEL}, MACHINE:${MACHINE}"
    # exit 1
fi

wget --no-check-certificate -qO "/tmp/n2n.zip" "https://raw.githubusercontent.com/lucktu/n2n/master/$(echo ${KERNEL} | sed -e 's/\b\(.\)/\u\1/g')${SRC_DIR:+/$SRC_DIR}/${FILE_NAME}"

unzip -o -d /tmp/n2n/ /tmp/n2n.zip 

if ls /tmp/n2n/n2n*; then
    mv /tmp/n2n/n2n*/* /tmp/n2n/
    rm -r /tmp/n2n/n2n*/
fi

if [[ -d "/tmp/n2n/static" ]]; then
    cp -r /tmp/n2n/static/* /tmp/n2n/
fi

if [[ `ls /tmp/n2n/ | grep 'tar.gz'` ]] ; then
    LOG_INFO "发现多文件，即将解压最大文件"
    tar -zxvf "$(find /tmp/n2n -type f -print0 | xargs -0 du -h | sort -rh | head -n 1  | awk '{print$2}')" -C /tmp/n2n/ 
fi

if [[ ! -f /tmp/n2n/supernode  ]]; then
    LOG_INFO "发现多文件，即将解压最大 static"
    tar -zxvf "$(find /tmp/n2n/*static* -type f -print0 | xargs -0 du -h | sort -rh | head -n 1  | awk '{print$2}')" -C /tmp/n2n/ 
fi

chmod +x /tmp/n2n/*

ls -l /tmp/n2n
