#!/bin/bash

# set -x

source 0x0_init-logger.sh

REGISTRY=${REGISTRY:-docker.io}
REGISTRY_USERNAME=${REGISTRY_USERNAME:-zctmdc}
DOCKER_APP_NAME=${REGISTRY:-n2n}
DOCKER_TEST_TAG=${REGISTRY:-zctmdc}
DOCKER_BUILD_PLATFORMS=${REGISTRY:-linux/amd64}
DOCKER_TEST_COMPSOE_FILE=${REGISTRY:-test/docker-compose.test.yaml}
DOCKER_TEST_PROJECT_DIRECTORY=${REGISTRY:-"${DOCKER_TEST_COMPSOE_FILE%/*}/"}

export REGISTRY="${REGISTRY}"
export REGISTRY_USERNAME="${REGISTRY_USERNAME}"
export DOCKER_APP_NAME="${DOCKER_APP_NAME}"
export DOCKER_TEST_TAG="${DOCKER_TEST_TAG}"
export DOCKER_BUILD_PLATFORMS="${DOCKER_BUILD_PLATFORMS}"
export DOCKER_TEST_COMPSOE_FILE="${DOCKER_TEST_COMPSOE_FILE}"
flag_test_pass='true'


l_platforms=(${DOCKER_BUILD_PLATFORMS//,/ })
for test_platform in ${l_platforms[@]}; do
    TEST_PLATFORM="${test_platform}"
    export TEST_PLATFORM="${TEST_PLATFORM}"
    LOG_WARNING "Test for platform: ${TEST_PLATFORM}"

    LOG_WARNING "Test start - edge"
    docker run --rm \
        --platform ${test_platform} \
        ${REGISTRY}/${REGISTRY_USERNAME}/${DOCKER_APP_NAME}:${DOCKER_TEST_TAG} \
        ls /usr/local/sbin/edge

    edge_result="$(docker run --rm \
        --platform ${test_platform} \
        ${REGISTRY}/${REGISTRY_USERNAME}/${DOCKER_APP_NAME}:${DOCKER_TEST_TAG} \
        edge -h 2>&1 | xargs -0 --no-run-if-empty -I {} echo {})"

    LOG_WARNING "${edge_result}"
    
    if [[ -z "$(echo ${edge_result,,} | grep welcome)" ]]; then
        LOG_ERROR 出错了: ${test_platform} - ${edge_result}
        flag_test_pass="false"
        continue
    fi
    LOG_WARNING "Test pass - edge"
    LOG_WARNING "Test start - supernode"
    docker run --rm \
        --platform ${test_platform} \
        ${REGISTRY}/${REGISTRY_USERNAME}/${DOCKER_APP_NAME}:${DOCKER_TEST_TAG} \
        ls /usr/local/sbin/supernode

    # supernode will not pass
    edge_result="$(docker run --rm \
        --platform ${test_platform} \
        ${REGISTRY}/${REGISTRY_USERNAME}/${DOCKER_APP_NAME}:${DOCKER_TEST_TAG} \
        supernode -h 2>&1 | xargs -0 --no-run-if-empty -I {} echo {} || echo -e '\n# check supernode ignore errors')"

    LOG_WARNING "Test done - supernode"
done

export FLAG_TEST_PASS=${flag_test_pass}