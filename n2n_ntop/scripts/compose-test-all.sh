#!/bin/bash

# set -x
. init_logger.sh
set -e

export PROXY_SERVER="http://host.docker.internal:21089"

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

        docker_build_command="docker buildx build --progress plain \
                --platform '${TEST_PLATFORM}' \
                --build-arg VERSION_B_S_rC=${BUILD_VERSION_B_S_rC} \
                -f ../${build_docker_file}"

        if [[ -n "${PROXY_SERVER}" ]]; then
            docker_build_command="${docker_build_command} \
                --build-arg http_proxy=${PROXY_SERVER,,} \
                --build-arg https_proxy=${PROXY_SERVER,,}"
        fi

        LOG_RUN "${docker_build_command} \
                -t ${REGISTRY_USERNAME}/${APP_NAME}:${test_tag} \
                --load ../. "

        chmod +x *.sh
        sh -c ./compose-test.sh
        LOG_WARNING "Test done - ${test_platform}"
    done
    LOG_WARNING "Test done: ${BUILD_VERSION_B_S_rC}"
done
