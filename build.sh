#!/bin/bash
set -e

# Install Flutter if not already available
if ! command -v flutter &> /dev/null; then
  echo "Installing Flutter..."
  FLUTTER_VERSION="3.24.5"
  FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  
  curl -L "$FLUTTER_URL" | tar xJ
  export PATH="$PWD/flutter/bin:$PATH"
fi

# Verify Flutter installation
flutter --version

# Get dependencies
flutter pub get

echo "Dependencies installed successfully!"
