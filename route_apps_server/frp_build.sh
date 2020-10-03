frp_version=$(./bin/frps --version)
echo "frp version: $frp_version"
/tmp/frp/
git clone https://github.com/fatedier/frp.git /tmp/frp/
cd /tmp/frp/
./package.sh


cd /tmp/frp/release/packages/

os_all='linux windows darwin freebsd'
arch_all='386 amd64 arm arm64 mips64 mips64le mips mipsle'

for os in $os_all; do
    for arch in $arch_all; do
        frp_dir_name="frp_${frp_version}_${os}_${arch}"
        for frp_action in frpc frps; do
            if [ "x${os}" = x"windows" ]; then
                zip -rq ${frp_dir_name}.zip
                cp -f ${frp_dir_name}/${frp_action}.exe $FRP_OPT_DIR/${frp_action}_${os}_${arch}.exe
            else
                tar -zxf ${frp_dir_name}.tar.gz
                cp -f ${frp_dir_name}/${frp_action} $FRP_OPT_DIR/${frp_action}_${os}_${arch}
            fi
        done
    done
done

cd -
