#!/bin/bash
set -e

# Install Flutter if not already available
if ! command -v flutter &> /dev/null; then
  echo "Installing Flutter..."
  FLUTTER_VERSION="3.24.5"
  FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  
  curl -L "$FLUTTER_URL" | tar xJ
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
