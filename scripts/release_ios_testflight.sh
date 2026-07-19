#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -d ios ]; then
  echo "No iOS project in $ROOT_DIR"
  exit 0
fi

: "${ASC_KEY_ID:?Missing ASC_KEY_ID}"
: "${ASC_ISSUER_ID:?Missing ASC_ISSUER_ID}"
: "${ASC_PRIVATE_KEY:?Missing ASC_PRIVATE_KEY content}"

mkdir -p "$HOME/.appstoreconnect/private_keys"
printf '%s' "$ASC_PRIVATE_KEY" > "$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
chmod 600 "$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"

flutter pub get
flutter build ipa --release --export-method app-store

ipa=$(ls build/ios/ipa/*.ipa | head -1)
xcrun altool --upload-app --type ios --file "$ipa" --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"

echo "$ipa"
