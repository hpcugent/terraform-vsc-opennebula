#!/bin/bash
: "${ROOT_DIR:=$(pwd)}"

if [[ -f "common.sh" ]];then
    source common.sh
elif [[ -d tests ]];then
    source tests/common.sh
else
    error "Can't find common.sh!"
fi
find "$ROOT_DIR" -type f -name '*.tf' -print0 |
while IFS= read -r -d '' file; do
    if grep -q "../../" "$file"; then
        error "Local module reference detected in ${file#"$ROOT_DIR"/}"
    fi
done
