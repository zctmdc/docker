#!/bin/bash
. init_logger.sh
### 自动识别系统类型
sel_os() {
    uos=$(uname -s | tr '[A-Z]' '[a-z]')
    case $uos in
    *linux*)
        myos="linux"
        ;;
    *dragonfly*)
        myos="dragonfly"
        ;;
    *freebsd*)
        myos="freebsd"
        ;;
    *openbsd*)
        myos="openbsd"
        ;;
    *netbsd*)
        myos="netbsd"
        ;;
    *darwin*)
        myos="macosx"
        ;;
    *aix*)
        myos="aix"
        ;;
    *solaris* | *sun*)
        myos="solaris"
        ;;
    *haiku*)
        myos="haiku"
        ;;
    *mingw* | *msys*)
        myos="windows"
        ;;
    *android*)
        myos="android"
        ;;
    *)
        LOG_ERROR "识别失败的系统 - $uos"
        exit 1
        ;;
    esac
    LOG_INFO "识别成功的系统 - $myos"
}

### 自动识别CPU架构
sel_cpu() {
    ucpu=$(uname -m | tr '[A-Z]' '[a-z]')
    case $ucpu in
    *i386* | *i486* | *i586* | *i686* | *bepc* | *i86pc*)
        mycpu="i386"
        ;;
    *amd*64* | *x86-64* | *x86_64*)
        mycpu="amd64"
        ;;
    *sparc* | *sun*)
        mycpu="sparc"
        if [ "$myos" = "linux" ]; then
            if [ "$(getconf LONG_BIT)" = "64" ]; then
                mycpu="sparc64"
            elif [ "$(isainfo -b)" = "64" ]; then
                mycpu="sparc64"
            fi
        fi
        ;;
    *ppc64le*)
        mycpu="powerpc64el"
        ;;
    *ppc64*)
        mycpu="powerpc64"
        ;;
    *power* | *ppc*)
        if [ "$myos" = "freebsd" ]; then
            mycpu="$(uname -p)"
        else
            mycpu="powerpc"
        fi
        ;;
    *ia64*)
        mycpu="ia64"
        ;;
    *m68k*)
        mycpu="m68k"
        ;;
    *mips*)
        case $ucpu in
        mips | mipsel | mips64 | mips64el)
            mycpu=$ucpu
            ;;
        *)
            LOG_ERROR "分析失败的CPU架构类型 - 未知的 MIPS : $ucpu"
            exit 1
            ;;
        esac
        ;;
    *alpha*)
        mycpu="alpha"
        ;;
    *arm* | *armv6l* | *armv71*)
        mycpu="arm"
        ;;
    *aarch64eb*)
        mycpu="arm64eb"
        ;;
    *aarch64*)
        mycpu="arm64"
        ;;
    *riscv64*)
        mycpu="riscv64"
        ;;
    *)
        LOG_ERROR "分析失败的CPU架构类型 - $ucpu"
        exit 1
        ;;
    esac
    LOG_INFO "分析成功的CPU架构类型 - $mycpu"
}
myos=""
mycpu=""
sel_os
sel_cpu

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
    arm64eb)
        MACHINE="arm64eb(aarch64eb)"
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
