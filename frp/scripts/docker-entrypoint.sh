#!/bin/sh

MODE=${1:-$MODE}

EXEC_PATH=/usr/bin
CONF_PATH=/etc/frp
CONF_FRPS_BAK_PATH=/opt/frp/bak
CONF_ADD_PATH=/opt/frp/conf
CONF_ADD_PATH=/opt/frp/conf/add/

EXEC_FILE_FRPS=${EXEC_PATH}/frps
EXEC_FILE_FRPC=${EXEC_PATH}/frpc

CONF_FRPS=${CONF_PATH}/frps.ini
CONF_FRPC=${CONF_PATH}/frpc.ini

CONF_FRPS_MD5=${CONF_FRPS_BAK_PATH}/etc_frps.ini.md5
CONF_FRPC_MD5=${CONF_FRPS_BAK_PATH}/etc_frpc.ini.md5

CONF_FRPS_BAK=${CONF_FRPS_BAK_PATH}/frps.ini
CONF_FRPC_BAK=${CONF_FRPS_BAK_PATH}/frpc.ini

CONF_FRPS_ADD=${CONF_ADD_PATH}/frps_add.ini
CONF_FRPC_ADD=${CONF_ADD_PATH}/frpc_add.ini

CONF_FRPS_ADD_MD5=${CONF_FRPS_BAK_PATH}/frps_add.ini.md5
CONF_FRPC_ADD_MD5=${CONF_FRPS_BAK_PATH}/frpc_add.ini.md5

FLAG_CONF_ADD='###DOCER_CONF_ADD###'

sum_file_save() {
    sum_src_file="$1"
    sum_save_file="$2"
    if [ -z "${sum_src_file}" ] || [ -z "${sum_save_file}" ]; then
        echo "FAILED arg empty - 1:${sum_src_file} - 2:${sum_save_file}" >&2
        echo "FAILED"
        return 1
    fi
    if [ ! -r "${sum_src_file}" ]; then
        echo "FAILED non-readable - ${sum_src_file}" >&2
        return 1
    fi
    sum_save_path="${sum_save_file%/*}"
    if [ -n "${sum_save_path}" ] || [ ! -w "${sum_save_path}"]; then
        echo "FAILED non-writable - ${sum_save_path}" >&2
        return 1
    fi
    sha256sum "${sum_src_file}" >"${sum_save_file}"
    if [ "$?" == "0" ]; then
        echo "OK"
        return 0
    else
        echo "FAILED sha256sum ${sum_src_file} - ${sum_save_file}" >&2
        return 1
    fi
}

sum_file_check() {
    sum_save_file="$1"
    if [ -z "${sum_save_file}" ]; then
        echo "FAILED arg empty - 1:${sum_save_file}" >&2
        return 1
    fi
    if [ ! -r "${sum_save_file}" ]; then
        echo "FAILED non-readable - ${sum_save_file}" >&2
        return 1
    fi
    if cat "${sum_save_file}" | sha256sum --check | grep "OK" >/dev/null; then
        # OK
        echo "OK"
        return 1
    else
        # FAILED
        echo "FAILED sha256sum --check ${sum_save_file}" >&2
        return 0
    fi
}

check_conf_changed() {
    sum_src_file="$CONF_FILE"
    sum_save_file="$CONF_FILE_MD5"
    if sum_file_check "${sum_save_file}" >/dev/null 2>&1; then
        # Not Change
        echo "Not Change sum_file_check - $sum_src_file"
        return 0
    else
        # Modified
        echo "Modified   sum_file_check - $sum_src_file"
        return 1
    fi
}

check_conf_add_changed() {
    sum_src_file="$CONF_FILE_ADD"
    sum_save_file="$CONF_FILE_ADD_MD5"
    if sum_file_check "${sum_save_file}" >/dev/null 2>&1; then
        # Not Change
        echo "Not Change sum_file_check - $sum_src_file"
        return 0
    else
        # Modified
        echo "Modified   sum_file_check - $sum_src_file"
        return 1
    fi
}

is_not_edit_pass_web() {
    check_file="${1:-${CONF_FILE}}"
    if [ ! -r "${check_file}" ]; then
        echo "FAILED non-readable - ${check_file}" >&2
        return 1
    fi
    # 是否从网页更改
    if cat "$CONF_FILE" | grep 'Envs.SUBDOMAIN_HOST' >/dev/null 2>&1; then
        # Not Change
        echo "Not Change pass_web - $check_file"
        return 0
    else
        # Modified
        echo "Modified   pass_web - $check_file"
        return 1
    fi
}
is_edit_conf_pass_add() {
    check_file="${1:-${CONF_FILE}}"
    if [ ! -r "${check_file}" ]; then
        echo "FAILED non-readable - ${check_file}" >&2
        return 1
    fi
    if cat "$check_file" | grep "$FLAG_CONF_ADD" >/dev/null 2>&1; then
        # Not Change
        echo "Not Change pass_add - $check_file"
        return 0
    else
        # Modified
        echo "Modified   pass_add - $check_file"
        return 1
    fi
}

run_frp() {
    if [ -r "${CONF_FILE_MD5}" ] && check_conf_changed >/dev/null; then
        echo "FAILED 配置文件已经改变 - ${CONF_FILE}"
        echo "##################"
        cat "${CONF_FILE}"
        echo "##################"
        cp -f "${CONF_FILE}" "$(date +%Y-%m-%d--%H-%M-%S)-${CONF_FILE}.bak"
    fi

    if is_not_edit_pass_web && -f ${CONF_FILE}; then
        # 还原配置文件
        echo "RUN 还原配置文件 - ${CONF_FILE_BAK}"
        cp $CONF_FILE_BAK $CONF_FILE
        chmod +w $CONF_FILE
    fi

    if is_not_edit_pass_web && -r ${CONF_FILE_ADD}; then
        # 拼接配置文件
        echo "RUN 拼接配置文件 - ${CONF_FILE_ADD}"

        echo "" >>$CONF_FILE
        echo "$FLAG_CONF_ADD" >>$CONF_FILE
        echo "" >>$CONF_FILE
        cat $CONF_FILE_ADD >>$CONF_FILE
        echo "" >>$CONF_FILE
    fi
    if is_not_edit_pass_web && -r ${CONF_ADD_PATH}; then
        for src_file in $(find "${CONF_ADD_PATH}" -name '*.ini'); do
            if [ ! -r "$src_file" ]; then
                continue
            fi
            echo "RUN 拼接配置文件 - ${src_file}"

            echo "" >>$CONF_FILE
            echo "$FLAG_CONF_ADD" >>$CONF_FILE
            echo "" >>$CONF_FILE
            # 拼接配置文件
            cat "$src_file" >>$CONF_FILE
            echo "" >>$CONF_FILE
        done
    fi

    if [ !-x $EXEC_FILE ]; then
        echo "FAILED non-executable - ${EXEC_FILE}" >&2
        exit 1
    fi
    if [ -r $CONF_FILE]; then
        echo "FAILED non-readable   - ${CONF_FILE}" >&2
        exit 1
    fi
    # 保存校验信息
    echo "RUN 保存校验信息 - ${CONF_FILE_MD5}"
    sum_file_save "${CONF_FILE}" "${CONF_FILE_MD5}"
    # RUN IT
    echo "RUN ${EXEC_FILE} -c ${CONF_FILE}"
    exec $EXEC_FILE -c $CONF_FILE
    exit $?
}

if [ "$(echo ${MODE}  | tr a-z A-Z)" = "RUN_FRPS" ]; then
    # FRPS
    echo "RUN FRPS"

    EXEC_FILE=$EXEC_FILE_FRPS
    CONF_FILE=$CONF_FRPS
    CONF_FILE_MD5=$CONF_FRPS_MD5
    CONF_FILE_BAK=$CONF_FRPS_BAK
    CONF_FILE_ADD=$CONF_FRPS_ADD
    CONF_FILE_ADD_MD5=$CONF_FRPS_ADD_MD5
    run_frp
elif [ "$(echo ${MODE}  | tr a-z A-Z)" = "RUN_FRPC" ]; then
    # FRPC
    echo "RUN FRPC"

    EXEC_FILE=$EXEC_FILE_FRPC
    CONF_FILE=$CONF_FRPC
    CONF_FILE_MD5=$CONF_FRPC_MD5
    CONF_FILE_BAK=$CONF_FRPC_BAK
    CONF_FILE_ADD=$CONF_FRPC_ADD
    CONF_FILE_ADD_MD5=$CONF_FRPC_ADD_MD5
    run_frp
fi

exec "$@"
exit $?
