#!/bin/bash
set -e

# Install Flutter if not already available
if ! command -v flutter &> /dev/null; then
  echo "Installing Flutter..."
  # Use a newer Flutter version that includes Dart 3.9.2+
  # Flutter 3.27.0 or later should include Dart 3.9.2+
  # If this version doesn't exist, try 3.28.0 or check latest stable
  FLUTTER_VERSION="3.27.0"
  FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  
  echo "Downloading Flutter ${FLUTTER_VERSION}..."
  curl -L "$FLUTTER_URL" | tar xJ
  
  # Fix git ownership warning for Flutter SDK
  git config --global --add safe.directory "$PWD/flutter" || true
fi

# Ensure PATH is set for this session
export PATH="$PWD/flutter/bin:$PATH"

# Verify Flutter installation
echo "Flutter version:"
flutter --version

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build for web
echo "Building web app..."
flutter build web --release

echo "Build completed successfully!"
