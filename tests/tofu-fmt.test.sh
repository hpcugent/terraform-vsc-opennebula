#!/bin/bash
if [[ -f "common.sh" ]];then
    source common.sh
elif [[ -d tests ]];then
    source tests/common.sh
else
    error "Can't find common.sh!"
fi
: "${ROOT_DIR:=$(pwd)}"
ORIGINAL_DIR="$(pwd)"
cd "$ROOT_DIR"
if ! tofu fmt -check -recursive -list=false ;then
    error "Unformatted files detected:" noexit
    error "$(tofu fmt -check -recursive)" noexit
    error "Please run \"tofu fmt -recursive\""
fi
cd "$ORIGINAL_DIR"
