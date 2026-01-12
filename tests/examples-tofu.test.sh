#!/bin/bash
if [[ -f "common.sh" ]];then
    source common.sh
elif [[ -d tests ]];then
    source tests/common.sh
else
    error "Can't find common.sh!"
fi
: "${ROOT_DIR:=$(pwd)}"

LOCALMODE=false
while IFS= read -r -d '' file; do
    info "checking $file"
    if grep -q "../../" "$file"; then
        LOCALMODE=true
        info "$(grep -q "../../" "$file")"
    fi
done < <(find "$ROOT_DIR" -type f -name '*.tf' -print0)
if ! $LOCALMODE;then
  info "Setting examples to local mode"
  bash -c "$ROOT_DIR/fixup-examples.sh local"
fi

FAILED_EXAMPLES=()
for example in "$ROOT_DIR"/examples/*; do
  cd "$example"
  tofu init 1>/dev/null

  if ! tofu test; then
    FAILED_EXAMPLES+=("$(basename "$example")")
  fi
  cd "$ROOT_DIR"
done

if ! $LOCALMODE;then
  info "Setting examples back to remote mode"
  bash -c "$ROOT_DIR/fixup-examples.sh remote"
fi



if [ "${#FAILED_EXAMPLES[@]}" -ne 0 ]; then
  error "The following examples failed:" noexit
  for fail in "${FAILED_EXAMPLES[@]}"; do
    error "* $fail/" noexit
  done
  exit 1
fi

success "All examples passed"
