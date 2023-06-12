#!/bin/bash

WAIT_DEBUG=${WAIT_DEBUG:-}
VERSION_BIG=${VERSION_BIG:-}
VERSION_SMALL=${VERSION_SMALL:-}
VERSION_COMMIT=${VERSION_COMMIT:-}
VERSION_B_S_rC=${VERSION_B_S_rC:-}

LOG_INFO() {
  echo -e $(caller) "\033[0;32m[    INFO] $@ \033[0m"
}

LOG_ERROR() {
  echo -e $(caller) "\033[0;31m[   ERROR] $@ \033[0m"
  if [[ -n "${WAIT_DEBUG}" ]]; then
    sleep 3
  fi
}

LOG_ERROR_WAIT_EXIT() {
  echo -e $(caller) "\033[0;31m[   ERROR] $@ \033[0m"
  t=30
  while test $t -gt 0; do
    if [ $t -ge 10 ]; then
      echo -e "${t}\b\b\c"
    elif [ $t -eq 9 ]; then
      echo -e "  \b\c"
      echo -e "\b${t}\b\c"
    else
      echo -e "${t}\b\c"
    fi
    sleep 1
    t=$((t - 1))
  done

  exit 1
}

LOG_WARNING() {
  echo -e $(caller) "\033[0;33m[ WARNING] $@ \033[0m"
  if [[ -n "${WAIT_DEBUG}" ]]; then
    sleep 1
  fi
}

LOG_RUN() {
  echo -e $(caller) "\033[102;35m[    RUN] $@ \033[0m"
  eval "$@"
}

LOG_INPTU() {
  LOG_INFO "input: VERSION_BIG: ${VERSION_BIG}"
  LOG_INFO "input: VERSION_SMALL: ${VERSION_SMALL}"
  LOG_INFO "input: VERSION_COMMIT: ${VERSION_COMMIT}"
  LOG_INFO "input: VERSION_B_S_rC: ${VERSION_B_S_rC}"
}

LOG_INFO "init_logger success - $(caller)"
