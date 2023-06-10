# 编译帮助

## 版本说明

![版本说明](https://github.com/lucktu/other/raw/master/image/speed/19102501.PNG)

## 编译方法

### 手动编译

### 编译全部版本

> 新代码未适配

<!--
1. 克隆此项目

2. 进入 `scripts` 目录

    ```shell
    cd scripts
    ```

3. 编辑 `build-manual.sh` 文件

    将 `REGISTRY` 替换为你自己的
    国内用户请可以使用 `PROXY_SERVER`
    你可以在此处修改编译输出的信息 `scan_one_build.sh`

4. 运行 `build-manual.sh`

    - `sh ./scan_all_save.sh` 说明

        1. 列出 `Linux` 目录下所有文件
        2. 解析版本信息
        3. 保存至 `result` 文件夹
           _e.g._ v3_3.1.1-16_r1200.txt

            ```text
            $ cat result/v3_3.1.1-16_r1200.txt
            arm64
            arm64eb
            armeb
            arm
            mips64el
            mips64
            mipsel
            mips
            x64
            x86
            ```

    - `sh ./scan_all_build.sh` 说明

        1. 列出 `result` 下版本文件
        2. 解析版本信息
        3. 复制所需文件至 `result/build_src/`
        4. 执行编译命令

    - `. scan_one_build.sh` 说明

        加载 `SCAN_ONE_BUILD` 方法, 此方法用于解析一个版本号进行编译

    - 编译大版本
      遍历 `v1`, `v2`, `v2s`
      调用 `SCAN_ONE_BUILD` 编译 -->

### 编译指定版本

多平台编译准备

`docker run --privileged --rm tonistiigi/binfmt --install all`

`docker buildx create --use --name build --node build --driver-opt network=host`

> see: <https://docs.docker.com/engine/reference/commandline/buildx/>

> 新代码未适配

<!--
手动编译

    ```shell
    cd scripts/
    . scan_one_build.sh
    SCAN_ONE_BUILD v2
    SCAN_ONE_BUILD v2_2.7.0_r528
    ``` -->

## 使用 `GitHub Actions`

1. 启用 `GitHub Actions`

   see: <https://docs.github.com/cn/actions/quickstart>

2. 触发调用

   1. `n2n_00x00_manual-scan-all-to-build` 参数说明

      参见 `n2n_00x00_manual-scan-all-to-build.yml` 文件

      - 触发器

        1. 手动触发 `workflow_dispatch`

      - `env`

        参照页面提示

      see: <https://docs.github.com/cn/actions/using-workflows/triggering-a-workflow>

      see: <https://docs.github.com/cn/actions/learn-github-actions/environment-variables>

      see: <https://docs.github.com/cn/actions/using-jobs/using-a-matrix-for-your-jobs>

## 容器说明

n2n:downloader

- 输入合适的参数
- 复制对应的文件至 `/tmp/down`
- 递归`/tmp/down`下压缩包及其内所有压缩文件
- 解压至其压缩文件无后缀所命名的文件夹中
- 选择最大 `edge` 文件所在目录，复制至 `/tmp/desc` `file`

| FILE                | 定义                           | 说明                                          |
| :------------------ | :----------------------------- | :-------------------------------------------- |
| Dockerfile.build.\* | `debian` / `ubuntu` / `alpine` | 优先使用最新稳定版, 已修复 `libssl1.0.0` 问题 |
| Dockerfile.run      | 看编译源                       | 带脚本的，可以提取输入的参数/参数文件         |

| SOFT            | COMMAND                                                   | 说明                                                            |
| :-------------- | :-------------------------------------------------------- | :-------------------------------------------------------------- |
| net-tools       | _e.g._ `ifconfig edge0`                                   | `edge` need `ifconfig`                                          |
| busybox         | _e.g._ `busybox ping` `busybox ifconfig` `busybox udhcpd` | see <https://www.busybox.net/downloads/BusyBox.html>            |
| iptables        | _e.g._ `iptables -A FORWARD -i n2n0 -o eth0 -j ACCEPT`    | see <https://github.com/ntop/n2n/blob/dev/doc/Routing.md>       |
| isc-dhcp-server | _e.g._ `iptables -A FORWARD -i n2n0 -o eth0 -j ACCEPT`    | see <https://help.ubuntu.com/community/isc-dhcp-server>         |
| isc-dhcp-client | _e.g._ `iptables -A FORWARD -i n2n0 -o eth0 -j ACCEPT`    | see <https://kb.isc.org/docs/isc-dhcp-44-manual-pages-dhclient> |

### 参数说明

|               ARG | 示例                 |     定义 | 说明                                        |
| ----------------: | :------------------- | -------: | :------------------------------------------ |
|       VERSION_BIG | v3                   |   大版本 | `v1` , `v2` , `v2s` , `v3`                  |
|     VERSION_SMALL | 3.1.1-16             |   小版本 | `(?<=v)\d\.\d\.\d`                          |
|    VERSION_COMMIT | 1200                 |   提交号 | `(?<=_r).+?(?=[._])`                        |
|    VERSION_B_S_rC | v2s_2.1.0_r111       |   版本号 | `v2s_2.1.0_r111` `v2_2.3.0` `v2s` `v2` `v1` |
| STR_DOWNLOAD_URLS | [<https://....tar.gz>](https://raw.githubusercontent.com/lucktu/n2n/master/Linux/n2n_v3_linux_x64_v3.1.1_r1255_static_by_heiye.tar.gz) | 下载地址 | 暂未使用，使用文件传进来的                  |
