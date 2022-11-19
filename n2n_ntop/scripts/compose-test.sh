#!/bin/bash

# set -x
. init_logger.sh

if [[ -z "${compsoe_file}" ]]; then
    compsoe_file="../docker-compose.test.yaml"
fi
if [[ -z "${APP_NAME}" ]]; then
    APP_NAME="n2n_ntop"
fi
if [[ -z "${REGISTRY_USERNAME}" ]]; then
    REGISTRY_USERNAME="zctmdc"
fi
if [[ -z "${test_tag}" ]]; then
    test_tag="test"
fi
if [[ -z "${test_platform}" ]]; then
    test_platform="linux/amd64"
fi
if [[ -z "${build_docker_file}" ]]; then
    build_docker_file="Dockerfile"
fi
if [[ -z "${BUILD_VERSION_B_S_rC}" ]]; then
    BUILD_VERSION_B_S_rC="latest"
fi

export REGISTRY_USERNAME="${REGISTRY_USERNAME}"
export APP_NAME="${APP_NAME}"
export test_tag="${test_tag}"
export TEST_PLATFORM="${test_platform}"
export build_docker_file="${build_docker_file}"
TOTLA_WAIT_TIME=$((60 * 10))

pull() {
    if [[ "${test_tag}" == "test" ]]; then
        return
    fi
    LOG_RUN docker compose -f "${compsoe_file}" pull
}
build() {
    if [[ "${need_build^^}" != "TRUE" ]]; then
        return
    fi
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
        count_healthy=$(echo "${run_status}" | grep '(healthy)' | wc -l)
        count_starting=$(echo "${run_status}" | grep '(starting)' | wc -l)
        count_created=$(echo "${run_status}" | grep '(created)' | wc -l)

        LOG_INFO "### run_status:\n${run_status}"
        LOG_INFO "count_healthy: ${count_healthy} / count_all_runing: ${count_all_runing}"

        if [[ "${count_all_runing}" == "${count_healthy}" ]]; then
            LOG_INFO "已通过:${test_platform}${platforms:+ - }${platforms} - ${count_healthy}/${count_all_runing} - ${sumTime}s"
            return 0
        else
            LOG_WARNING "测试中:${test_platform}${platforms:+ - }${platforms} - ${count_healthy}/${count_all_runing} - ${sumTime}s\n"
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
