#!/bin/sh
set -e

# Install Flutter
export HOME=/Users/local
export PUB_CACHE="${HOME}/.pub-cache"

FLUTTER_VERSION="3.44.1"
FLUTTER_DIR="${HOME}/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_${FLUTTER_VERSION}-stable.tar.xz" \
    -o /tmp/flutter.tar.xz
  tar xf /tmp/flutter.tar.xz -C "${HOME}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

# Run from the repo root (ci_post_clone.sh runs inside ios/ci_scripts)
cd "${CI_PRIMARY_REPOSITORY_PATH}"

flutter pub get
