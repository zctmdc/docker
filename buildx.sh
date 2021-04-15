if [[ ! $(docker buildx ls | grep remotebuilder) ]]; then

    ARM64=ssh://root@192.168.169.66
    AMD64=ssh://root@192.168.169.58

    ## 注意: 这里指定名称 remotebuilder
    DOCKER_HOST=${AMD64} docker buildx create --name remotebuilder --node zctmdc-amd64 --platform=amd64
    ### --append 表示追加， 而非重新创建
    DOCKER_HOST=${ARM64} docker buildx create --append --name remotebuilder --node zctmdc-arm64 --platform=arm64
fi

## 使用 remotebuilder
docker buildx use remotebuilder

## 查看 remotebuilder 状态
docker buildx ls --builder remotebuilder
skip_path="caddy my_settings"
for project in $(ls); do
    if [[ -d $project && "*$project*" != "${skip_path}" ]]; then
        docker buildx build --platform=linux/amd64,linux/arm64 --tag zctmdc/${project}:Alpha --push ./${project}
    fi
done
