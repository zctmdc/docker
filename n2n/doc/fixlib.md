# 修复缺少 lib 错误


## 依赖安装

### ubuntu/debian 安装

```shell
apt-get update
apt-get install -y wget unzip
```

### alpine 安装

```shell
apk add --no-cache wget unzip
```

## 问题修复

### /lib/ld-linux.so.3

> qemu-arm: Could not open '/lib/ld-linux.so.3': No such file or directory

-   docker run command

    ```shell
    docker run -ti --rm --platform linux/arm/v7 ubuntu:18.04 bash
    ```

-   ubuntu 换源

    [ubuntu 换源](##换源)

-   ubuntu 依赖安装

    [ubuntu 安装](##依赖安装)

-   Source file

    ```shell
    cd /tmp/
    wget \
    https://github.com/lucktu/n2n/raw/master/Linux/Old/linux_arm/n2n_v2_linux_arm_v2.3.0_2.zip
    unzip n2n_v2_linux_arm_v2.3.0_2.zip
    chmod +x edge2 supernode2
    ```

-   fix command

    ```shell
    if [[ $(./edge2 -h 2>&1 | grep  /lib/ld-linux.so.3) ]];then
        find / -name ld-linux*.so* |  head -n 1 | xargs -I {} ln -sv {} /lib/ld-linux.so.3
    fi
    ```

    ```shell
    ./edge2 -h
    ```

### libcrypto.so.1.0.0

缺少 libssl1.0.0

> error while loading shared libraries: libcrypto.so.1.0.0: cannot open shared object file: No such file or directory

-   使用支持的系统版本

    -   `debian:8`
    -   `debian:jessie`
    -   `ubuntu:18.04`
    -   `ubuntu:bionic`
    -   `alpine:3.8` \*_可能不起作用_

-   或手动安装

    -   ubuntu

        <https://pkgs.org/download/libssl1.0.0>  
        <http://archive.ubuntu.com/ubuntu/pool/main/o/openssl1.0/>

    -   debian

        <https://security.debian.org/debian-security/pool/updates/main/o/openssl/>

-   docker run command

    ```shell
    docker run -ti --rm --platform linux/amd64 ubuntu:18.04 bash
    ```

-   ubuntu 换源

[ubuntu 换源](##国内换源)

-   ubuntu 安装软件包

[ubuntu 安装](##依赖安装)

-   Source file

    ```shell
    cd /tmp/
    wget \
    https://github.com/zctmdc/n2n-lucktu/raw/master/Linux/Old/linux_x64/n2n_v2_linux_x64_v2.4.0_r71.zip
    unzip n2n_v2_linux_x64_v2.4.0_r71.zip
    chmod +x edge2 supernode2
    ```

-   fix command

    see: <https://github.com/zctmdc/docker/blob/alpha/n2n/scripts/build/3x0_n2n_fixlib.sh>


    ```shell
    ./edge2 -h
    ```

### 手动修复

```console
# ldd edge2
    libcrypto.so.1.1 => not found
    libc.so.6 => /lib/arm-linux-gnueabihf/libc.so.6 (0x3f708000)
    /lib/ld-linux-armhf.so.3 (0x40000000)
```

Google: `libcrypto.so.1.1` `not found`

```console
./edge2
    ./edge2: error while loading shared libraries: libcrypto.so.1.1: cannot open shared object file: No such file or directory
```

Google: `error while loading shared libraries` `libcrypto.so.1.1`

[libcryptoso1.0.0](###libcryptoso1.0.0)



## 国内换源

### deiabn 换源

```shell
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list
```

### ubuntu 换源

```shell
sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
sed -i 's/ports.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
```

### alpine 换源

```shell
sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
apk add --no-cache bash
bash
```

## 代理加速

```shell
proxy_server='http://host.docker.internal:21089'
export http_proxy="${proxy_server}"
export https_proxy="${proxy_server}"
export ALL_PROXY="${proxy_server}"
```