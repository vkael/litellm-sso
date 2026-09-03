#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

upstream_url="https://github.com/BerriAI/litellm.git"

if ! git remote get-url upstream >/dev/null 2>&1; then
    echo "Add upstream"
    git remote add upstream "$upstream_url"
fi

echo "Fetch upstream"
git fetch upstream 'refs/tags/*:refs/tags/*'

latest_tag="$(
    git ls-remote --tags --refs upstream 'v*' |
        sed 's#.*refs/tags/##' |
        grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' |
        sort -V |
        tail -1
)"

if [ -z "$latest_tag" ]; then
    echo "Could not determine latest stable upstream tag" >&2
    exit 1
fi

sso_tag="${latest_tag}-sso"

echo "Syncing main to upstream $latest_tag"

git checkout main

if git rev-parse "$sso_tag" >/dev/null 2>&1; then
    echo "tag $sso_tag already exists" >&2
    exit 1
fi

# We intentionally allow changes under patches/*.
if git diff --quiet -- . ':!patches' && \
   git diff --cached --quiet -- . ':!patches'; then
    :
else
    echo "working tree has changes outside patches/" >&2
    git status --short
    exit 1
fi

git sparse-checkout disable 2>/dev/null || true

# Record the complete local patches tree in a temporary Git commit.
git add -A patches
patch_commit="$(
    git write-tree |
        xargs git commit-tree -p HEAD -m "temporary local patches"
)"

# Reset main to the upstream tag.
git reset --hard "$latest_tag"

# Restore our patches from the temporary Git commit.
git restore --source="$patch_commit" --staged --worktree -- patches

# Patching time
git apply patches/0001-free-oidc-and-remove-enterprise.patch

sed -i "s/%TAG%/$latest_tag/g" patches/HEADER.md
cat patches/HEADER.md README.md | tee README.md

git add -A
git commit -m "chore: sync with upstream $latest_tag"

echo "Push to origin main"
git push --force-with-lease origin main

echo "Create signed tag $sso_tag"
git tag "$sso_tag" -m "LiteLLM $latest_tag with SSO"

echo "Push $sso_tag"
git push origin "$sso_tag"

echo "Sync to $latest_tag done"

