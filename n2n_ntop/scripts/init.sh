#!/bin/bash
### 自定义日志功能
zctmdc_logger() {
    logger -t "【ZCTMDC】" "$*"
    echo "$*"
}

# 输出命令到日志并运行
zctmdc_logger_run() {
    zctmdc_logger "$*"
    bash -c "$*"
}

#睡眠功能
zctmdc_sleep() {
    zctmdc_logger_run "sleep ${*}"
}

### 自动识别系统类型
zctmdc_sel_os() {
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
        zctmdc_logger "【错误】 系统类型识别失败 - $uos"
        exit 1
        ;;
    esac
    zctmdc_logger "【成功】 系统类型识别成功 - $myos"
}

### 自动识别CPU架构
zctmdc_sel_cpu() {
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
            zctmdc_logger "【错误】 CPU架构类型识别失败: 未知的 MIPS - $ucpu"
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
    *aarch64*)
        mycpu="arm64"
        ;;
    *riscv64*)
        mycpu="riscv64"
        ;;
    *)
        zctmdc_logger "【错误】 CPU架构类型识别失败 - $ucpu"
        exit 1
        ;;
    esac
    zctmdc_logger "【成功】 CPU架构类型识别成功 - $mycpu"
}
### 自动识别系统平台
myos=""
mycpu=""
zctmdc_sel_os &&
    zctmdc_sel_cpu