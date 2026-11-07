#!/bin/zsh
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KEY_ID="3U5GRBXLAR"
ISSUER_ID="47e0206d-5840-4dbb-b8d7-80f19523322d"
KEY_FILE="$PROJECT_DIR/AuthKey_3U5GRBXLAR.p8"

cd "$PROJECT_DIR"

if [ ! -f "$PROJECT_DIR/build/ios/ipa/Goalverse.ipa" ]; then
  echo "=== Building Signed App Store IPA ==="
  flutter build ipa --release --export-options-plist="$PROJECT_DIR/ios/ExportOptions.plist"
fi

IPA_FILE=$(ls "$PROJECT_DIR/build/ios/ipa/"*.ipa | head -n 1)
echo "[OK] Ready to upload signed IPA: $IPA_FILE"

mkdir -p "$PROJECT_DIR/private_keys"
cp -f "$KEY_FILE" "$PROJECT_DIR/private_keys/AuthKey_${KEY_ID}.p8"

echo "=== 1. Uploading Signed IPA to App Store Connect / TestFlight ==="
xcrun altool --upload-app \
  --type ios \
  --file "$IPA_FILE" \
  --apiKey "$KEY_ID" \
  --apiIssuer "$ISSUER_ID"

echo "=== 2. Syncing 6-Language Metadata & 48 iOS Screenshots via App Store Connect API ==="
dart run scripts/asc_api_setup_and_sync.dart
