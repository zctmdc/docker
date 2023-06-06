#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

source 0x0_init_logger.sh

LOG_INFO "scan_all_do start"
##########

LOG_INFO "creating .venv"
python -m venv .venv
LOG_INFO "activate .venv"
source .venv/bin/activate
LOG_INFO "install requirements"
pip install -r requirements.txt
LOG_INFO "run scan_all_n2n.py"
python scan_all_n2n.py
LOG_INFO "echo to GITHUB_OUTPUT"
echo "matrix_json=$(cat dict_build_obj.json)" >>  $GITHUB_OUTPUT

##########
LOG_INFO "scan_all_do finish"
