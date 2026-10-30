#!/usr/bin/env bash
# Optional first argument: a config commit to reproduce instead of master.
set -euo pipefail

checkout=$(mktemp -d "${TMPDIR:-/tmp}/homeconfig.XXXXXX")
trap 'rm -rf -- "$checkout"' EXIT
git clone --quiet --depth=1 --filter=blob:none --sparse --branch master \
  https://github.com/Jac-Zac/My-home-config.git "$checkout/repo"
if [ "$#" -gt 0 ]; then
  git -C "$checkout/repo" fetch --quiet --depth=1 origin "$1"
  git -C "$checkout/repo" checkout --quiet --detach FETCH_HEAD
fi
git -C "$checkout/repo" sparse-checkout set HPC_config
printf 'Config commit: %s\n' "$(git -C "$checkout/repo" rev-parse HEAD)"
bash "$checkout/repo/HPC_config/setup.sh"
