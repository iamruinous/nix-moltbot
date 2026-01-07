#!/bin/sh
set -e

store_path_file="${PNPM_STORE_PATH_FILE:-.pnpm-store-path}"
store_path="$(mktemp -d)"

printf "%s" "$store_path" > "$store_path_file"

fetcherVersion=$(cat "$PNPM_DEPS/.fetcher-version" 2>/dev/null || echo 1)
if [ "$fetcherVersion" -ge 3 ]; then
  tar --zstd -xf "$PNPM_DEPS/pnpm-store.tar.zst" -C "$store_path"
else
  cp -Tr "$PNPM_DEPS" "$store_path"
fi

chmod -R +w "$store_path"

# pnpm --ignore-scripts marks tarball deps as "not built" and offline install
# later refuses to use them; if a dep doesn't require build, promote it.
"$PROMOTE_PNPM_INTEGRITY_SH" "$store_path"

export REAL_NODE_GYP="$(command -v node-gyp)"
wrapper_dir="$(mktemp -d)"
install -Dm755 "$NODE_GYP_WRAPPER_SH" "$wrapper_dir/node-gyp"
export PATH="$wrapper_dir:$PATH"
