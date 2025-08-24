#!/usr/bin/env bash
set -euo pipefail

# Auto hot-reload runner for Flutter on Android emulator (macOS friendly).
# - Boots emulator if needed
# - Runs `flutter run` and captures its PID
# - Watches for changes in lib/ and pubspec.yaml and sends SIGUSR1 (hot reload)
#
# Usage:
#   tools/run_android_autoreload.sh [AVD_NAME]
#
# Notes:
# - SIGUSR1 triggers hot reload, SIGUSR2 would trigger hot restart.
# - This uses a portable polling-based watcher (no extra brew deps).

DEFAULT_AVD_NAME="Pixel_8a"
AVD_NAME="${1:-$DEFAULT_AVD_NAME}"

ANDROID_SDK="$HOME/Library/Android/sdk"
EMULATOR_BIN="$ANDROID_SDK/emulator/emulator"
ADB_BIN="$ANDROID_SDK/platform-tools/adb"

if ! command -v flutter >/dev/null 2>&1; then
  echo "[!] flutter not found in PATH. Please ensure Flutter SDK is installed and on PATH."
  exit 1
fi

if [[ ! -x "$EMULATOR_BIN" ]]; then
  echo "[!] Emulator binary not found at $EMULATOR_BIN"
  echo "    Make sure Android SDK is installed."
  exit 1
fi

has_emulator_online() {
  "$ADB_BIN" devices 2>/dev/null | awk 'NR>1 && $1 ~ /emulator-/ && $2 == "device" { found=1 } END { exit(found?0:1) }'
}

if ! has_emulator_online; then
  echo "[i] Launching emulator: $AVD_NAME"
  nohup "$EMULATOR_BIN" -avd "$AVD_NAME" -netdelay none -netspeed full >/dev/null 2>&1 &
else
  echo "[i] An Android emulator is already online."
fi

echo "[i] Waiting for emulator to boot..."
"$ADB_BIN" wait-for-device
while [[ "$($ADB_BIN shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]]; do
  sleep 1
  printf '.'
done
printf "\n[i] Emulator booted.\n"

DEVICE_ID=$("$ADB_BIN" devices | awk 'NR>1 && $1 ~ /emulator-/ && $2 == "device" { print $1; exit }')
if [[ -z "$DEVICE_ID" ]]; then
  echo "[!] Could not determine emulator device ID"
  exit 1
fi

# Start flutter run with a PID file so we can signal it.
RUN_PID_FILE=".flutter_run.pid"
rm -f "$RUN_PID_FILE"

echo "[i] Starting flutter run on $DEVICE_ID (PID will be stored in $RUN_PID_FILE)"
# Use script to ensure the child PID is written. We use --pid-file for support in newer SDKs; fallback if missing.
set +e
flutter run -d "$DEVICE_ID" --pid-file "$RUN_PID_FILE" &
FLUTTER_RUN_SHELL_PID=$!
set -e

# Wait for pid file to appear (flutter writes it when tool is fully started).
for i in {1..60}; do
  if [[ -s "$RUN_PID_FILE" ]]; then
    break
  fi
  sleep 0.5
 done

if [[ ! -s "$RUN_PID_FILE" ]]; then
  echo "[!] Could not obtain flutter run PID (pid file not found)."
  echo "    Auto-reload will not be available; attach manually using terminal keys."
  wait "$FLUTTER_RUN_SHELL_PID"
  exit $?
fi

FLUTTER_RUN_PID=$(cat "$RUN_PID_FILE")
echo "[i] flutter run PID: $FLUTTER_RUN_PID"

# Build a portable change signature for watched files (mac/BSD compatible)
current_sig() {
  # Collect modification time and path for Dart sources and pubspec.yaml
  # macOS BSD find lacks -printf; use stat -f
  {
    find lib -type f -name "*.dart" -print0 2>/dev/null | xargs -0 stat -f '%m %N' 2>/dev/null || true
    if [[ -f pubspec.yaml ]]; then stat -f '%m %N' pubspec.yaml; fi
  } | shasum | awk '{print $1}'
}

LAST_SIG="$(current_sig || true)"
if [[ -z "$LAST_SIG" ]]; then LAST_SIG=0; fi

echo "[i] Auto hot-reload is active. Editing files in lib/ or pubspec.yaml will trigger reload."

# Watch loop
while kill -0 "$FLUTTER_RUN_SHELL_PID" 2>/dev/null; do
  sleep 0.7
  SIG_NOW="$(current_sig || true)"
  if [[ -z "$SIG_NOW" ]]; then SIG_NOW=$LAST_SIG; fi
  if [[ "$SIG_NOW" != "$LAST_SIG" ]]; then
    LAST_SIG="$SIG_NOW"
    if kill -0 "$FLUTTER_RUN_PID" 2>/dev/null; then
      echo "\n[i] Changes detected → Hot reload"
      kill -USR1 "$FLUTTER_RUN_PID" || true
    fi
  fi
 done

# Propagate exit
wait "$FLUTTER_RUN_SHELL_PID" || true
