#!/usr/bin/env bash

set -euo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly FLUTTER_VERSION="${FLUTTER_VERSION:-3.38.9}"
readonly FLUTTER_HOME="${FLUTTER_HOME:-$PROJECT_ROOT/.netlify/flutter}"

cd "$PROJECT_ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
    git clone --depth 1 --branch "$FLUTTER_VERSION" \
      https://github.com/flutter/flutter.git "$FLUTTER_HOME"
  fi
  export PATH="$FLUTTER_HOME/bin:$PATH"
fi

flutter config --no-analytics
flutter pub get
flutter build web --release --no-wasm-dry-run
