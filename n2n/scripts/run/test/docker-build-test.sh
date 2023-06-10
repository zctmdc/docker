#!/bin/bash

# set -x

source init_logger.sh

REGISTRY=${REGISTRY:-docker.io}
REGISTRY_USERNAME=${REGISTRY_USERNAME:-zctmdc}
DOCKER_APP_NAME=${DOCKER_APP_NAME:-n2n}
DOCKER_TEST_TAG=${DOCKER_TEST_TAG:-zctmdc}
DOCKER_BUILD_PLATFORMS=${DOCKER_BUILD_PLATFORMS:-linux/amd64}
DOCKER_TEST_COMPSOE_FILE=${DOCKER_TEST_COMPSOE_FILE:-test/docker-compose.test.yaml}
DOCKER_TEST_PROJECT_DIRECTORY=${DOCKER_TEST_PROJECT_DIRECTORY:-"${DOCKER_TEST_COMPSOE_FILE%/*}/"}

export REGISTRY="${REGISTRY}"
export REGISTRY_USERNAME="${REGISTRY_USERNAME}"
export DOCKER_APP_NAME="${DOCKER_APP_NAME}"
export DOCKER_TEST_TAG="${DOCKER_TEST_TAG}"
export DOCKER_BUILD_PLATFORMS="${DOCKER_BUILD_PLATFORMS}"
export DOCKER_TEST_COMPSOE_FILE="${DOCKER_TEST_COMPSOE_FILE}"
flag_test_pass='true'

TOTLA_WAIT_TIME=$((60 * 10))

pull() {
    if [[ -n "$(docker images --format '{{ .Repository }}:{{ .Tag }}' | grep ${REGISTRY_USERNAME}/${DOCKER_APP_NAME}:${DOCKER_TEST_TAG})" ]]; then
        return
    fi
    LOG_RUN docker compose -f "${DOCKER_TEST_COMPSOE_FILE}" pull
}
start() {
    LOG_RUN docker compose --project-directory "${DOCKER_TEST_PROJECT_DIRECTORY}" -f "${DOCKER_TEST_COMPSOE_FILE}" up -d
}
stop() {
    LOG_RUN docker compose -f "${DOCKER_TEST_COMPSOE_FILE}" down
}
check_status() {
    startTime=$(date +%Y%m%d-%H:%M:%S)
    startTime_s=$(date +%s)

    while true; do
        nowTime=$(date +%Y%m%d-%H:%M:%S)
        nowTime_s=$(date +%s)
        sumTime=$(($nowTime_s - $startTime_s))

        run_status="$(docker compose -f ${DOCKER_TEST_COMPSOE_FILE} ps)"
        count_all_runing=$(echo "${run_status}" | grep test-n2n | wc -l)
        count_healthy=$(echo "${run_status}" | grep '(healthy)' | wc -l)
        count_starting=$(echo "${run_status}" | grep '(starting)' | wc -l)
        count_created=$(echo "${run_status}" | grep '(created)' | wc -l)

        LOG_INFO "### run_status:\n${run_status}"
        LOG_INFO "count_healthy: ${count_healthy} / count_all_runing: ${count_all_runing}"

        if [[ "${count_all_runing}" == "${count_healthy}" ]]; then
            LOG_INFO "已通过:${DOCKER_BUILD_PLATFORMS}${platforms:+ - }${platforms} - ${count_healthy}/${count_all_runing} - ${sumTime}s"
            return 0
        else
            LOG_WARNING "测试中:${DOCKER_BUILD_PLATFORMS}${platforms:+ - }${platforms} - ${count_healthy}/${count_all_runing} - ${sumTime}s\n"
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
    pull
    LOG_INFO "即将启动"
    start >>/dev/null &
    # start
    LOG_INFO "测试中"
    sleep 10
    check_status
    status_code=$?
    LOG_INFO "测试结果 status_code: ${status_code}"
    stop
    LOG_INFO "测试结束"
    return ${status_code}
}

case $1 in
check_status)
    LOG_INFO "检查状态中"
    check_status
    ;;
*)
    flag_test_pass='true'
    l_platforms=(${DOCKER_BUILD_PLATFORMS//,/ })
    main_code=0
    for test_platform in ${l_platforms[@]}; do
        TEST_PLATFORM="${test_platform}"
        export TEST_PLATFORM="${TEST_PLATFORM}"
        LOG_WARNING "Test START platform: ${TEST_PLATFORM}"
        main
        if [[ "${status_code}" != "0" ]];then
            main_code="${status_code}"
        fi
        LOG_WARNING "Test DONE  platform: ${TEST_PLATFORM}"
    done
    if [[ "${status_code}" != "0" ]];then
        flag_test_pass="false"
    fi
    ;;
esac

export FLAG_TEST_PASS=${flag_test_pass}