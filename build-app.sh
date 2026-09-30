#!/bin/sh

set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
APP="$ROOT/dist/WakeUp.app"
CONTENTS="$APP/Contents"
ICONSET="$ROOT/.build/WakeUp.iconset"

cd "$ROOT"
swift build -c release

rm -rf "$APP" "$ICONSET"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources" "$ICONSET"
cp ".build/release/WakeUp" "$CONTENTS/MacOS/WakeUp"
cp "App/Info.plist" "$CONTENTS/Info.plist"
swift "App/generate-icon.swift" "$ICONSET"
iconutil --convert icns --output "$CONTENTS/Resources/WakeUp.icns" "$ICONSET"
rm -rf "$ICONSET"

codesign --force --sign - "$APP"
printf 'Built %s\n' "$APP"
