#!/usr/bin/env bash
# Source this file so the selected Flutter SDK remains on PATH.
set -euo pipefail
FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.2}"
if command -v flutter >/dev/null 2>&1 && [[ "$(flutter --version 2>/dev/null)" == "Flutter $FLUTTER_VERSION "* ]]; then
  return 0
fi
CIRTA_FLUTTER_DIR="${NETLIFY_BUILD_BASE:-$PWD}/.netlify/flutter-$FLUTTER_VERSION"
if [[ ! -x "$CIRTA_FLUTTER_DIR/bin/flutter" ]]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$CIRTA_FLUTTER_DIR"
fi
export PATH="$CIRTA_FLUTTER_DIR/bin:$PATH"
flutter config --no-analytics
