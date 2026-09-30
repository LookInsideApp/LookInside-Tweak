#!/bin/bash
# Copies the iOS device slice of LookInsideServer.xcframework into the
# package layout and signs it with ldid.
#
# Usage:
#   Scripts/fetch-server.sh
#       Downloads LookInsideServer.xcframework.zip from the latest
#       LookInside-Release release.
#   SERVER_XCFRAMEWORK=/path/to/LookInsideServer.xcframework Scripts/fetch-server.sh
#       Uses a local build instead.
#
# Env knobs:
#   SERVER_XCFRAMEWORK  local LookInsideServer.xcframework to use
#   SERVER_VERSION      release tag to download (default: latest)
#
# System apps such as SpringBoard and Settings are arm64e processes and can
# only load a Server that has an arm64e slice. Third-party apps load arm64.

set -euo pipefail

cd "$(dirname "$0")/.."

RELEASE_REPO="https://github.com/LookInsideApp/LookInside-Release"
DESTINATION="layout/Library/Frameworks/LookInsideServer.framework"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

xcframework="${SERVER_XCFRAMEWORK:-}"
if [ -z "$xcframework" ]; then
	version="${SERVER_VERSION:-}"
	if [ -n "$version" ]; then
		url="$RELEASE_REPO/releases/download/$version/LookInsideServer.xcframework.zip"
	else
		url="$RELEASE_REPO/releases/latest/download/LookInsideServer.xcframework.zip"
	fi
	echo "==> Downloading $url"
	curl -fL --retry 3 -o "$WORK_DIR/server.zip" "$url"
	ditto -x -k "$WORK_DIR/server.zip" "$WORK_DIR"
	xcframework="$WORK_DIR/LookInsideServer.xcframework"
fi

slice=""
for candidate in "$xcframework"/ios-arm64*; do
	case "$candidate" in
	*simulator*) continue ;;
	esac
	if [ -d "$candidate/LookInsideServer.framework" ]; then
		slice="$candidate/LookInsideServer.framework"
		break
	fi
done
if [ -z "$slice" ]; then
	echo "No iOS device slice in $xcframework" >&2
	exit 1
fi

echo "==> Installing $slice"
rm -rf "$DESTINATION"
mkdir -p "$(dirname "$DESTINATION")"
cp -R "$slice" "$DESTINATION"
rm -rf "$DESTINATION/Modules" "$DESTINATION/Headers" "$DESTINATION/_CodeSignature"
ldid -S "$DESTINATION/LookInsideServer"

archs="$(lipo -archs "$DESTINATION/LookInsideServer")"
echo "==> Server architectures: $archs"
case " $archs " in
*" arm64e "*) ;;
*) echo "warning: no arm64e slice, so system apps cannot load this Server" >&2 ;;
esac
