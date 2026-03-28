#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
APP_NAME="Kerri LSAT Writing.app"
APP_DIR="$BUILD_DIR/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
WEB_DIR="$RESOURCES_DIR/Web"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$WEB_DIR"

swiftc \
  -parse-as-library \
  "$ROOT_DIR/macos-app/LSATWritingMac.swift" \
  -framework Cocoa \
  -framework WebKit \
  -o "$MACOS_DIR/KerriLSATWriting"

cp "$ROOT_DIR/macos-app/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/macos-app/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
cp "$ROOT_DIR/index.html" "$WEB_DIR/index.html"
cp "$ROOT_DIR/manifest.webmanifest" "$WEB_DIR/manifest.webmanifest"
cp "$ROOT_DIR/service-worker.js" "$WEB_DIR/service-worker.js"
cp "$ROOT_DIR/icon.svg" "$WEB_DIR/icon.svg"

echo "Built macOS app bundle at:"
echo "  $APP_DIR"
