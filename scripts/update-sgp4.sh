#!/usr/bin/env bash
#
# Re-vendors the upstream sgp4 library (https://github.com/dnwrnr/sgp4) into Sources/sgp4Lib
# at the given git ref, along with its LICENSE, and records the resolved commit in
# Sources/sgp4Lib/UPSTREAM_REVISION.
#
# Usage: scripts/update-sgp4.sh <tag-or-commit>

set -euo pipefail

UPSTREAM_URL="https://github.com/dnwrnr/sgp4.git"

if [[ $# -ne 1 ]]; then
    echo "usage: $0 <tag-or-commit>" >&2
    exit 64
fi

ref="$1"
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
target="$repo_root/Sources/sgp4Lib"
checkout="$(mktemp -d)"
trap 'rm -rf "$checkout"' EXIT

git clone --quiet --no-checkout "$UPSTREAM_URL" "$checkout"
git -C "$checkout" checkout --quiet --detach "$ref"
revision="$(git -C "$checkout" rev-parse HEAD)"

# Wipe before copying so files renamed or deleted upstream don't linger.
find "$target" -maxdepth 1 -type f \( -name '*.cc' -o -name '*.cpp' \) -delete
find "$target/include" -maxdepth 1 -type f -name '*.h' -delete

find "$checkout/libsgp4" -maxdepth 1 -type f \( -name '*.cc' -o -name '*.cpp' \) -exec cp {} "$target/" \;
find "$checkout/libsgp4" -maxdepth 1 -type f -name '*.h' -exec cp {} "$target/include/" \;

# Upstream is Apache 2.0, which requires redistributing a copy of the license.
cp "$checkout/LICENSE" "$target/LICENSE"

echo "$revision" > "$target/UPSTREAM_REVISION"

echo "Vendored sgp4 at $revision. Review the diff and run 'swift test'."
