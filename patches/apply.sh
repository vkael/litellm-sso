#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

if [ -d enterprise ]; then
    git rm -rq enterprise
fi

for patch_file in patches/*.patch; do
    git apply --check "$patch_file"
done
for patch_file in patches/*.patch; do
    git apply "$patch_file"
done
