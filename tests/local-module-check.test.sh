#!/bin/bash
: "${ROOT_DIR:=$(pwd)}"

if [[ -f "common.sh" ]]; then
    source common.sh
elif [[ -d tests ]]; then
    source tests/common.sh
else
    echo "Can't find common.sh!" >&2
    exit 1
fi

version_file="$ROOT_DIR/VERSION.txt"

version=$(tr -d '[:space:]' < "$version_file")
#[[ -n "$expected" ]] || error "VERSION.txt is empty"

failed=0

while IFS= read -r -d '' file; do
    if ! grep -qF "\"$version\"" "$file"; then
        error "Version $version not found in ${file#"$ROOT_DIR"/}" noexit
        failed=1
    fi
done < <(find "$ROOT_DIR/examples" -maxdepth 2 -type f -name main.tf -print0)

if [[ "$failed" -ne 0 ]]; then
    exit 1
fi

success "All examples use version $version"
