#!/bin/bash

#  方法1
# if [[ ! $(docker buildx ls | grep remotebuilder) ]]; then

#     ARM=ssh://root@$ARM_SERVER
#     ARM64=ssh://root@$ARM64_SERVER
#     AMD64=ssh://root@$AMD64_SERVER

#     ## 注意: 这里指定名称 remotebuilder
#     DOCKER_HOST=${ARM64} docker buildx create --name remotebuilder --node zctmdc-arm64 --platform=arm64
#     ### --append 表示追加， 而非重新创建
#     DOCKER_HOST=${ARM} docker buildx create --append --name remotebuilder --node zctmdc-arm --platform=arm
#     DOCKER_HOST=${AMD64} docker buildx create --append --name remotebuilder --node zctmdc-amd64 --platform=amd64
# fi

# ## 使用 remotebuilder
# docker buildx use remotebuilder

# ## 查看 remotebuilder 状态
# docker buildx ls --builder remotebuilder

# 方法2
# add 2021-7-8
docker run --privileged --rm docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
if [[ ! $(docker buildx ls | grep all-pf-builder) ]]; then
  docker buildx create --name all-pf-builder
  docker buildx inspect --bootstrap
fi

## 使用 remotebuilder
docker buildx use all-pf-builder

## 查看 remotebuilder 状态
docker buildx ls --builder all-pf-builder

# PROXY_SERVER="HTTP://proxy-server:1080"

if [[ -z ${PROXY_SERVER} ]]; then
  echo "未设置代理服务 \${PROXY_SERVER}"
elif curl -k -sS -x ${PROXY_SERVER} --connect-timeout 5 https://github.com; then
  echo "使用代理服务器 \${PROXY_SERVER}:${PROXY_SERVER}"
  build_cmd="--build-arg ALL_PROXY=${PROXY_SERVER} \
      --build-arg HTTP_PROXY=${PROXY_SERVER} \
      --build-arg USE_PROXY=on \
      --build-arg all_proxy=${PROXY_SERVER} \
      --build-arg http_proxy=${PROXY_SERVER} \
      --build-arg use_proxy=on \
      --build-arg GO111MODULE=on \
      --build-arg GOPROXY=https://goproxy.io"
else
  echo "请检查代理服务 \${PROXY_SERVER}:${PROXY_SERVER}"
fi

cd /opt/docker
skip_path="caddy my_settings"
for project in $(ls); do
  if [[ -d ${project} && ${skip_path} != *${project}* ]]; then
    echo "build - ${project}"
    docker buildx build \
      --platform=linux/amd64,linux/arm64,linux/arm/v7 \
      ${build_cmd} \
      --tag zctmdc/${project}:Alpha \
      ./${project} \
      --push
  fi
done


PROXY_SERVER="HTTP://proxy-server:21089"
export  ALL_PROXY=${PROXY_SERVER} 
export  HTTP_PROXY=${PROXY_SERVER} 
export  USE_PROXY=on 
export  all_proxy=${PROXY_SERVER} 
export  http_proxy=${PROXY_SERVER} 
export  use_proxy=on 