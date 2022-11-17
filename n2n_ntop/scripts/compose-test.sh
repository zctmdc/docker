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

TOTLA_WAIT_TIME=$((60 * 10))

pull() {
    if [[ "${test_tag}" == "test" ]]; then
        return
    fi
    docker compose -f "${compsoe_file}" pull
}
start() {
    docker compose --project-directory "${compsoe_file%/*}/" -f "${compsoe_file}" up -d
}
stop() {
    docker compose -f "${compsoe_file}" down
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
        count_healthy=$(echo "${run_status}" | grep healthy | wc -l)
        count_healthy=$(echo "${run_status}" | grep healthy | wc -l)
        count_starting=$(echo "${run_status}" | grep starting | wc -l)
        count_created=$(echo "${run_status}" | grep created | wc -l)

        LOG_INFO "### run_status:\n${run_status}"
        LOG_INFO "count_healthy: ${count_healthy} / count_all_runing: ${count_all_runing}"

        if [[ "${count_all_runing}" == "${count_healthy}" ]]; then
            LOG_INFO "已通过: ${count_healthy}/${count_all_runing} - ${sumTime}s"
            return 0
        else
            LOG_WARNING "测试中: ${count_healthy}/${count_all_runing} - ${sumTime}s\n"
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
