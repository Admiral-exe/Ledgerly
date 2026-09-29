#!/bin/bash
set -e

echo "=== [1/4] Setting up Flutter SDK on Vercel ==="
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK (stable channel)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
else
  echo "Using cached Flutter SDK..."
fi

# Export Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

echo "=== [2/4] Flutter Environment Check ==="
flutter --version
flutter config --enable-web

echo "=== [3/4] Fetching Packages ==="
flutter pub get

echo "=== [4/4] Building Flutter Web Release ==="
flutter build web --release

echo "=== Build Verified: Contents of build/web ==="
ls -la build/web

echo "=== Vercel Build Completed Successfully! ==="
