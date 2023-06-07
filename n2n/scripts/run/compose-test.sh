#!/bin/bash

# set -x
. init_logger.sh


if [[ -z "${REGISTRY_USERNAME}" ]]; then
    REGISTRY_USERNAME="zctmdc"
fi
if [[ -z "${DOCKER_APP_NAME}" ]]; then
    DOCKER_APP_NAME="n2n"
fi
if [[ -z "${DOCKER_TEST_TAG}" ]]; then
    DOCKER_TEST_TAG="latest"
fi
if [[ -z "${TEST_PLATFORM}" ]]; then
    TEST_PLATFORM="linux/amd64"
fi
if [[ -z "${compsoe_file}" ]]; then
    compsoe_file="docker-compose.test.yaml"
fi
if [[ -z "${build_docker_file}" ]]; then
    build_docker_file="Dockerfile.run"
fi

export REGISTRY_USERNAME="${REGISTRY_USERNAME}"
export DOCKER_APP_NAME="${DOCKER_APP_NAME}"
export DOCKER_TEST_TAG="${DOCKER_TEST_TAG}"
export TEST_PLATFORM="${TEST_PLATFORM}"
export compsoe_file="${compsoe_file}"
export build_docker_file="${build_docker_file}"

TOTLA_WAIT_TIME=$((60 * 10))

pull() {
    if [[ -n "$( docker images --format '{{ .Repository }}:{{ .Tag }}' | grep ${REGISTRY_USERNAME}/${DOCKER_APP_NAME}:${DOCKER_TEST_TAG} )" ]]; then
        return
    fi
    LOG_RUN docker compose -f "${compsoe_file}" pull
}
start() {
    LOG_RUN docker compose --project-directory "${compsoe_file%/*}/" -f "${compsoe_file}" up -d
}
stop() {
    LOG_RUN docker compose -f "${compsoe_file}" down
}
check_status() {
    startTime=$(date +%Y%m%d-%H:%M:%S)
    startTime_s=$(date +%s)

    while true; do
        nowTime=$(date +%Y%m%d-%H:%M:%S)
        nowTime_s=$(date +%s)
        sumTime=$(($nowTime_s - $startTime_s))

        run_status="$(docker compose -f ${compsoe_file} ps)"
        count_all_runing=$(echo "${run_status}" | grep test-n2n | wc -l)
        count_healthy=$(echo "${run_status}" | grep '(healthy)' | wc -l)
        count_starting=$(echo "${run_status}" | grep '(starting)' | wc -l)
        count_created=$(echo "${run_status}" | grep '(created)' | wc -l)

        LOG_INFO "### run_status:\n${run_status}"
        LOG_INFO "count_healthy: ${count_healthy} / count_all_runing: ${count_all_runing}"

        if [[ "${count_all_runing}" == "${count_healthy}" ]]; then
            LOG_INFO "已通过:${TEST_PLATFORM}${platforms:+ - }${platforms} - ${count_healthy}/${count_all_runing} - ${sumTime}s"
            return 0
        else
            LOG_WARNING "测试中:${TEST_PLATFORM}${platforms:+ - }${platforms} - ${count_healthy}/${count_all_runing} - ${sumTime}s\n"
        fi

        if [[ ${sumTime} -gt ${TOTLA_WAIT_TIME} ]]; then
            LOG_ERROR "超时退出"
            return 1
        fi
        sleep 10
    done
}

main() {
    LOG_INFO "测试开始"
    stop
    build
    pull
    LOG_INFO "即将启动"
    start >>/dev/null &
    # start
    LOG_INFO "测试中"
    sleep 10
    check_status
    status_code=$?
    LOG_INFO "测试结果 ${status_code}"
    stop
    LOG_INFO "测试结束"
    exit ${status_code}
}

case $1 in
check_status)
    LOG_INFO "检查状态中"
    check_status
    ;;
*)
    main
    ;;
esac


        #   export REGISTRY_USERNAME="${{ secrets.REGISTRY_USERNAME }}"
        #   export DOCKER_APP_NAME="${{ inputs.DOCKER_APP_NAME }}"
        #   export DOCKER_TEST_TAG="${{ inputs.DOCKER_TEST_TAG }}"
        #   LOG_WARNING "Test start: ${{ steps.init-build-infos.outputs.BUILD_VERSION_B_S_rC }}"
        #   platforms=${{ steps.init-build-infos.outputs.TEST_PLATFORM }}
        #   l_platforms=(${platforms//,/ })
        #   for test_platform in ${l_platforms[@]};do
        #     LOG_WARNING "Test for platform: ${test_platform}"
        #     export TEST_PLATFORM="${test_platform}"
        #       chmod +x *.sh
        #       . ./compose-test.sh
        #     LOG_WARNING "Test done - ${test_platform}"
        #   done
        #   LOG_WARNING "Test done: ${{ steps.init-build-infos.outputs.BUILD_VERSION_B_S_rC }}"
        #   echo "build_dockerfile=Dockerfile">> $GITHUB_OUTPUT