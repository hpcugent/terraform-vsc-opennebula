#!/bin/bash
set -euo pipefail
: "${ROOT_DIR:=$(pwd)}"
source "$ROOT_DIR"/tests/common.sh
MODE="${1:-}"
: "${FIXUP_GIT_MODE:=false}"
if [[ "$MODE" != "remote" && "$MODE" != "local" ]]; then
  echo "Usage: $0 {remote|local}"
  exit 1
fi

LOCAL_BASE='"../../"'
REMOTE_BASE='"hpcugent/vsc/opennebula"'
LOCAL_ROUTER_BASE='"../../modules/router"'
REMOTE_ROUTER_BASE='"hpcugent/vsc/opennebula//submodules/router"'
VERSION='0.0.3'

find "$ROOT_DIR/examples" -type f -name 'main.tf' -print0 |
while IFS= read -r -d '' file; do
    if [[ "$MODE" == "remote" ]]; then
        sed -i \
        -e "s|$LOCAL_BASE|$REMOTE_BASE|g" \
        -e "s|$LOCAL_ROUTER_BASE|$REMOTE_ROUTER_BASE|g" \
        -e "s|^[[:space:]]*#\s*version.*$|  version = \"$VERSION\"|" \
        "$file" 
        tofu fmt -list=false "$file" 
        info "Updated: $file"
        if $FIXUP_GIT_MODE;then
            git add "$file"
        fi
    elif ! grep -q "# version" "$file"; then
        sed -i \
        -e "s|$REMOTE_BASE|$LOCAL_BASE|g" \
        -e "s|$REMOTE_ROUTER_BASE|$LOCAL_ROUTER_BASE|g" \
        -e "s|version *=|# version = |g" \
        "$file"
        tofu fmt -list=false "$file"
        info "Updated: $file" 
        if $FIXUP_GIT_MODE ;then
            git add "$file"
        fi
    fi
done
