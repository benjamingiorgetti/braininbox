#!/bin/sh
set -ex

echo "=== Brain Inbox: Xcode Cloud post-clone setup ==="

export HOME=/Users/local
export PUB_CACHE="${HOME}/.pub-cache"
FLUTTER_DIR="${HOME}/flutter"
REPO="${CI_PRIMARY_REPOSITORY_PATH}"
EPHEMERAL="${REPO}/ios/Flutter/ephemeral"
PLUGIN_PKG="${EPHEMERAL}/Packages/FlutterGeneratedPluginSwiftPackage"

if [ ! -d "${FLUTTER_DIR}" ]; then
  echo "Cloning Flutter stable..."
  git clone --depth 1 --branch stable \
    https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
else
  echo "Flutter already present."
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
flutter --version

cd "${REPO}"

echo "--- flutter pub get ---"
flutter pub get

echo "--- flutter precache (iOS engine binaries) ---"
flutter precache --ios

echo "--- flutter build ios --config-only ---"
flutter build ios --config-only --no-codesign

echo "--- Verifying FlutterGeneratedPluginSwiftPackage ---"
if [ ! -d "${PLUGIN_PKG}" ]; then
  echo "ERROR: ${PLUGIN_PKG} was not created by flutter build ios --config-only"
  echo "Contents of ${EPHEMERAL}:"
  ls -la "${EPHEMERAL}" || echo "(ephemeral dir missing)"
  exit 1
fi

echo "Package.swift present: $(ls ${PLUGIN_PKG}/Package.swift)"
echo ".packages dir: $(ls ${EPHEMERAL}/.packages 2>/dev/null | wc -l) entries"

# Note: pod install is handled automatically by Xcode Cloud after this script.
# Running it here causes conflicts when Podfile.lock is out of sync with pubspec.lock.

echo "=== Setup complete ==="
