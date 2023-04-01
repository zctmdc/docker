#!/bin/sh

MODE=${1:-$MODE}

CONF_FRPS=/etc/frp/frps.ini
CONF_FRPC=/etc/frp/frpc.ini

CONF_FRPS_BAK=/opt/frp/conf/frps_bak.ini
CONF_FRPC_BAK=/opt/frp/conf/frpc_bak.ini

CONF_FRPS_ADD=/opt/frp/conf/frps_add.ini
CONF_FRPC_ADD=/opt/frp/conf/frpc_add.ini

CONF_FRPS_ADD_BAK=/opt/frp/conf/frps_add_bak.ini
CONF_FRPC_ADD_BAK=/opt/frp/conf/frpc_add_bak.ini

FLAG_CONF_ADD='###DOCER_CONF_ADD###'

if [ "$(echo ${MODE} | tr 'a-z' 'A-Z')" = "RUN_FRPS" ]; then
    # FRPS
    EXEC_FILE=/usr/bin/frps
    CONF_FILE=$CONF_FRPS
    CONF_FILE_BAK=$CONF_FRPS_BAK
    CONF_FILE_ADD=$CONF_FRPS_ADD
    CONF_FILE_ADD_BAK=$CONF_FRPS_ADD_BAK
elif [ "$(echo ${MODE} | tr 'a-z' 'A-Z')" = "RUN_FRPC" ]; then
    # FRPC
    EXEC_FILE=/usr/bin/frpc
    CONF_FILE=$CONF_FRPC
    CONF_FILE_BAK=$CONF_FRPC_BAK
    CONF_FILE_ADD=$CONF_FRPC_ADD
    CONF_FILE_ADD_BAK=$CONF_FRPC_ADD_BAK
fi

if [ -z "$( cat $CONF_FILE | grep 'Envs.SUBDOMAIN_HOST') " ];then
    # Changed pass WEB
    FLAG_EDIT_CONF_PASS_WEB='Changed_Pass_WEB'
fi

if [ -n "$( cat $CONF_FILE | grep $FLAG_CONF_ADD )" ];then
    # Change pass CONF_ADD
    FLAG_EDIT_CONF_PASS_ADD='Changed_Pass_ADD'
fi
if [ -z "${FLAG_EDIT_CONF_PASS_WEB}" ]  && [ -z "${FLAG_EDIT_CONF_PASS_ADD}" ]; then
    cp $CONF_FILE $CONF_FILE_BAK
fi
if [ -f $CONF_FILE_ADD ]; then
    FLAG_EXIST_CONF_FILE_ADD="TRUE"
    if [ -z "${FLAG_EDIT_CONF_PASS_WEB}" ]  && [ -f $CONF_FILE_ADD_BAK ] && [ -n "$(grep -v -f $CONF_FILE_ADD $CONF_FILE_ADD_BAK)" ] ; then
        # Changed_CONF_FILE_ADD
        FLAG_EDIT_CONF_ADD="TRUE"
        cp $CONF_FILE_BAK $CONF_FILE
        FLAG_EDIT_CONF_PASS_ADD=''
    fi
    cp $CONF_FILE_ADD $CONF_FILE_ADD_BAK
    FLAG_EXIST_CONF_FILE_ADD_BAK="TRUE"
fi

if [ -z "${FLAG_EDIT_CONF_PASS_WEB}" ] && [ -n "${FLAG_EXIST_CONF_FILE_ADD_BAK}" ] && [ -z "${FLAG_EDIT_CONF_PASS_ADD}" ]; then
    echo '' >> $CONF_FILE
    echo "$FLAG_CONF_ADD" >> $CONF_FILE
    echo '' >> $CONF_FILE
    cat $CONF_FILE_ADD_BAK >> $CONF_FILE
fi

if [ -n $EXEC_FILE ]; then
    # RUN IT
    exec $EXEC_FILE -c $CONF_FILE
    exit $?
fi

exec $@
