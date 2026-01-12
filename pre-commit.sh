#!/bin/bash
set -euo pipefail
source ./tests/common.sh
if [[ ${1-default} == "install" ]];then
    cp "$0" .git/hooks/pre-commit
    exit 0
elif [[ ${1-default} == "uninstall" ]];then
    rm .git/hooks/pre-commit
    exit 0
fi

export ROOT_DIR="$(pwd)"
./tests/local-module-check.test.sh
./tests/tofu-fmt.test.sh
