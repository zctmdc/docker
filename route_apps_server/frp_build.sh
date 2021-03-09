git clone https://github.com/fatedier/frp.git /tmp/frp/
cd /tmp/frp/
./package.sh

frp_version=$(/tmp/frp/bin/frps --version)
echo "frp version: $frp_version"

cd /tmp/frp/release/packages/

replaseKV='
el-le
amd64-x64
386-x86
'
os_all='linux windows darwin freebsd'
arch_all='386 amd64 arm arm64 mips64 mips64le mips mipsle'

for build_os in ${os_all}; do
    for arch in ${arch_all}; do
        frp_dir_name="frp_${frp_version}_${build_os}_${arch}"
        for frp_action in frpc frps; do
            for line_rep in ${replaseKV}; do
                line_rep_k="${line_rep%-*}"
                line_rep_v="${line_rep#*-}"
                if [ "x${build_os}" = x"windows" ]; then
                    zip -rq ${frp_dir_name}.zip
                    cp -f ${frp_dir_name}/${frp_action}.exe $FRP_OPT_DIR/${frp_action}_${build_os}_${arch}.exe
                    if [[ "${arch}" == *"${line_rep_k}" ]]; then
                        cp -f ${frp_dir_name}/${frp_action}.exe $FRP_OPT_DIR/${frp_action}_${build_os}_${arch%%${line_rep_k}}${line_rep_v}.exe
                    fi
                    if [[ "${arch}" == *"${line_rep_v}" ]]; then
                        cp -f ${frp_dir_name}/${frp_action}.exe $FRP_OPT_DIR/${frp_action}_${build_os}_${arch%%${line_rep_v}}${line_rep_k}.exe
                    fi
                else
                    tar -zxf ${frp_dir_name}.tar.gz
                    cp -f ${frp_dir_name}/${frp_action} $FRP_OPT_DIR/${frp_action}_${build_os}_${arch}
                    if [[ "${arch}" == *"${line_rep_k}" ]]; then
                        cp -f ${frp_dir_name}/${frp_action} $FRP_OPT_DIR/${frp_action}_${build_os}_${arch%%${line_rep_k}}${line_rep_v}
                    fi
                    if [[ "${arch}" == *"${line_rep_v}" ]]; then
                        cp -f ${frp_dir_name}/${frp_action} $FRP_OPT_DIR/${frp_action}_${build_os}_${arch%%${line_rep_v}}${line_rep_k}
                    fi
                fi
            done
        done
    done
done &&
    echo ${frp_version} >${version_file} &&
    /usr/local/bin/qshell qupload ~/.qshell/qupload.conf
