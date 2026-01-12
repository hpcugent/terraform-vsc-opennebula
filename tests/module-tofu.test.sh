#!/bin/bash
source ./common.sh
: "${ROOT_DIR:=$(pwd)}"
ORIGINAL_DIR="$(pwd)"
cd $ROOT_DIR
tofu init 1>/dev/null
tofu test
cd $ORIGINAL_DIR
