#!/bin/bash
export ROOT_DIR="$(pwd)"
cd tests/
bash -c ./runAll.sh
cd "$ROOT_DIR"
