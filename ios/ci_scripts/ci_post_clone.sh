#!/bin/sh
set -e

echo "=== Brain Inbox: Xcode Cloud post-clone setup ==="

# Xcode Cloud sets HOME to /Users/local
export HOME=/Users/local
export PUB_CACHE="${HOME}/.pub-cache"

FLUTTER_DIR="${HOME}/flutter"

# Install Flutter via git clone (stable channel)
if [ ! -d "${FLUTTER_DIR}" ]; then
  echo "Cloning Flutter stable..."
  git clone --depth 1 --branch stable \
    https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
else
  echo "Flutter already present, skipping clone."
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

echo "Flutter version: $(flutter --version --machine 2>/dev/null | head -1 || echo unknown)"

# Move to project root
cd "${CI_PRIMARY_REPOSITORY_PATH}"

echo "Running flutter pub get..."
flutter pub get

echo "Generating iOS project config (creates FlutterGeneratedPluginSwiftPackage)..."
flutter build ios --config-only --no-codesign

echo "=== Setup complete ==="
