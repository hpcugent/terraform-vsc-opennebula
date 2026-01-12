#!/bin/bash
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
LIGHT_BLUE=$'\033[94m'
RESET=$'\033[0m'
error() {
  printf '%s%s%s\n' "$RED" "$1" "$RESET" >&2
  if [[ "${2-default}" != "noexit" ]];then
    exit 1
  fi
}

warn() {
  printf '%s%s%s\n' "$YELLOW" "$*" "$RESET" >&2
}

info() {
  printf '%s%s%s\n' "$LIGHT_BLUE" "$*" "$RESET"
}

success() {
  printf '%s%s%s\n' "$GREEN" "$*" "$RESET"
}
