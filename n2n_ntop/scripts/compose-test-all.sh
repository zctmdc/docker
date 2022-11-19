#!/bin/bash

# set -x
. init_logger.sh
set -e

# export PROXY_SERVER="http://host.docker.internal:21089"

docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --use --name build --node build --driver-opt network=host
build_version_b_s_rcs="v1,v2,v2s,v3"
l_build_version_b_s_rcs=(${build_version_b_s_rcs//,/ })
export REGISTRY_USERNAME="zctmdc"
export APP_NAME="n2n_ntop"
export test_tag="test"
export build_docker_file="Dockerfile"
for build_version_b_s_rc in ${l_build_version_b_s_rcs[@]}; do
    export BUILD_VERSION_B_S_rC="${build_version_b_s_rc}"
    LOG_WARNING "Test start: ${BUILD_VERSION_B_S_rC}"
    export platforms='linux/386,linux/arm/v7,linux/amd64,linux/arm64/v8'
    l_platforms=(${platforms//,/ })
    for test_platform in ${l_platforms[@]}; do
        LOG_WARNING "Test for platform: ${test_platform}"
        export TEST_PLATFORM="${test_platform}"

        chmod +x *.sh
        sh -c ./compose-test.sh
        LOG_WARNING "Test done - ${test_platform}"
    done
    LOG_WARNING "Test done: ${BUILD_VERSION_B_S_rC}"
done
