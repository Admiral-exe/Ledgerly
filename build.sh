#!/bin/bash
set -e

echo "=== Ledgerly Vercel Build Step ==="

# Check if Flutter SDK is available
if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK (stable channel)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
else
  echo "Flutter directory exists, using cached SDK..."
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

echo "Checking Flutter version..."
flutter --version

echo "Enabling Flutter Web..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Building release bundle for Web..."
flutter build web --release

echo "=== Build Complete! Output directory: build/web ==="
