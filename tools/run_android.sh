#!/usr/bin/env bash
set -euo pipefail

# Simple helper to boot an Android emulator (if needed) and run the Flutter app.
# Usage:
#   tools/run_android.sh [AVD_NAME]
# If AVD_NAME is omitted, defaults to Pixel_8a (change below if your AVD name differs).

DEFAULT_AVD_NAME="Pixel_8a"
AVD_NAME="${1:-$DEFAULT_AVD_NAME}"

ANDROID_SDK="$HOME/Library/Android/sdk"
EMULATOR_BIN="$ANDROID_SDK/emulator/emulator"
ADB_BIN="$ANDROID_SDK/platform-tools/adb"

if [[ ! -x "$EMULATOR_BIN" ]]; then
  echo "[!] Emulator binary not found at $EMULATOR_BIN"
  echo "    Make sure Android SDK is installed."
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "[!] flutter not found in PATH. Please ensure Flutter SDK is installed and on PATH."
  exit 1
fi

# Start emulator if none online
has_emulator_online() {
  "$ADB_BIN" devices 2>/dev/null | awk 'NR>1 && $1 ~ /emulator-/ && $2 == "device" { found=1 } END { exit(found?0:1) }'
}

if ! has_emulator_online; then
  echo "[i] Launching emulator: $AVD_NAME"
  nohup "$EMULATOR_BIN" -avd "$AVD_NAME" -netdelay none -netspeed full >/dev/null 2>&1 &
else
  echo "[i] An Android emulator is already online."
fi

# Wait for emulator to be fully booted
echo "[i] Waiting for emulator to boot..."
"$ADB_BIN" wait-for-device
# Wait for boot completion property
while [[ "$($ADB_BIN shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]]; do
  sleep 1
  printf '.'
done
printf "\n[i] Emulator booted.\n"

# Find first emulator ID
DEVICE_ID=$("$ADB_BIN" devices | awk 'NR>1 && $1 ~ /emulator-/ && $2 == "device" { print $1; exit }')
if [[ -z "$DEVICE_ID" ]]; then
  echo "[!] Could not determine emulator device ID"
  exit 1
fi

echo "[i] Running app on $DEVICE_ID"
exec flutter run -d "$DEVICE_ID"
