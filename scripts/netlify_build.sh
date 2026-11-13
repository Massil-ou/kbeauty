#!/usr/bin/env bash

set -euo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$PROJECT_ROOT"

source scripts/flutter_setup.sh

flutter config --no-analytics
flutter pub get
flutter build web --release --no-wasm-dry-run
