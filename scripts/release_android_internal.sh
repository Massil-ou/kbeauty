#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -d android ]; then
  echo "No Android project in $ROOT_DIR"
  exit 0
fi

if [ ! -f android/key.properties ]; then
  echo "Missing android/key.properties. Use the keystore info from ~/Desktop/cicd-secrets."
  exit 1
fi

flutter pub get
flutter build appbundle --release

version=$(awk '/^version:/ {split($2,a,"+"); print a[1]; exit}' pubspec.yaml)
app=$(basename "$ROOT_DIR")
out_dir="${RELEASE_DIR:-$HOME/Desktop/releases}"
mkdir -p "$out_dir"
cp build/app/outputs/bundle/release/app-release.aab "$out_dir/${app}-${version}-release.aab"
echo "$out_dir/${app}-${version}-release.aab"
