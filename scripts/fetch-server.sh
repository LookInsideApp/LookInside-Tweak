#!/usr/bin/env bash
#
# fetch-server.sh — download the pinned LookInside Server XCFramework, verify
# its sha256 against configuration/server.env, and unpack the iOS device slice.
# Prints the path of the unpacked LookInsideServer.framework on the LAST line of
# stdout. The download is cached in $BUILD_DIR/server and checked again on every
# run, so a stale or tampered cache never reaches a package.
#
#   fetch-server.sh
#
# SERVER_XCFRAMEWORK=/path/to/LookInsideServer.xcframework uses a local build
# instead, for trying a Server change on a device. It skips the pin, so it is a
# development path only: Release never sets it.

set -Eeuo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
# shellcheck source=../configuration/server.env
source "$root/configuration/server.env"
: "${SERVER_NAME:?}" "${SERVER_URL:?}" "${SERVER_SHA256:?}"
[[ "$SERVER_SHA256" =~ ^[0-9a-f]{64}$ ]] || { echo "error: SERVER_SHA256 is not a sha256" >&2; exit 65; }

build_dir="${BUILD_DIR:-$root/build}"
cache="$build_dir/server"
mkdir -p "$cache"

xcframework="${SERVER_XCFRAMEWORK:-}"
if [[ -n "$xcframework" ]]; then
    [[ -d "$xcframework" ]] || { echo "error: SERVER_XCFRAMEWORK not found: $xcframework" >&2; exit 66; }
    echo "warning: using the local Server at $xcframework, not the pinned $SERVER_VERSION" >&2
else
    zip="$cache/$SERVER_NAME-$SERVER_VERSION.xcframework.zip"
    if [[ ! -f "$zip" ]] || [[ "$(shasum -a 256 "$zip" | cut -d' ' -f1)" != "$SERVER_SHA256" ]]; then
        echo "==> Downloading $SERVER_URL" >&2
        curl -fsSL --retry 3 -o "$zip.part" "$SERVER_URL"
        mv -f "$zip.part" "$zip"
    fi
    got="$(shasum -a 256 "$zip" | cut -d' ' -f1)"
    [[ "$got" == "$SERVER_SHA256" ]] || {
        rm -f "$zip"
        echo "error: $SERVER_NAME $SERVER_VERSION sha256 is $got, server.env pins $SERVER_SHA256" >&2
        exit 65
    }
    echo "==> $SERVER_NAME $SERVER_VERSION matches the pin (sha256 $got)" >&2
    unpacked="$cache/$SERVER_VERSION"
    rm -rf "$unpacked"
    mkdir -p "$unpacked"
    ditto -x -k "$zip" "$unpacked"
    xcframework="$unpacked/$SERVER_NAME.xcframework"
fi

# The device slice, never the simulator one.
slice=""
for candidate in "$xcframework"/ios-arm64*; do
    case "$candidate" in *simulator*) continue ;; esac
    if [[ -f "$candidate/$SERVER_NAME.framework/$SERVER_NAME" ]]; then
        slice="$candidate/$SERVER_NAME.framework"
        break
    fi
done
[[ -n "$slice" ]] || { echo "error: no iOS device slice in $xcframework" >&2; exit 65; }
echo "==> $SERVER_NAME slices: $(lipo -archs "$slice/$SERVER_NAME")" >&2
printf '%s\n' "$slice"
