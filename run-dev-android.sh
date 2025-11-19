#!/bin/bash
# 🚀 Quick Development Script for Android

set -e

PROJECT_ROOT="/Volumes/DATA/SourceCode/VuDe/react-native-kbzpay"
EXAMPLE_DIR="$PROJECT_ROOT/example"

echo "🚀 Starting React Native KBZPay Development..."
echo ""

# Check if we're in the right directory
cd "$PROJECT_ROOT"

# Kill existing Metro bundler if running
echo "🔄 Checking for existing Metro bundler..."
lsof -ti:8081 | xargs kill -9 2>/dev/null && echo "✅ Stopped existing Metro" || echo "✅ No existing Metro found"

# Start Metro Bundler in background
echo "📦 Starting Metro bundler..."
cd "$EXAMPLE_DIR"
yarn start > /tmp/metro-bundler.log 2>&1 &
METRO_PID=$!
echo "✅ Metro bundler started (PID: $METRO_PID)"

# Wait for Metro to be ready
echo "⏳ Waiting for Metro to initialize..."
sleep 5

# Check if device is connected
echo "📱 Checking Android device..."
if ! adb devices | grep -q "device$"; then
    echo "❌ No Android device found!"
    echo "Please connect a device or start an emulator"
    kill $METRO_PID 2>/dev/null
    exit 1
fi

echo "✅ Device connected"

# Build and run on Android
echo "🔨 Building and installing on Android..."
cd "$EXAMPLE_DIR"
yarn android

echo ""
echo "✅ Development environment ready!"
echo ""
echo "📝 Quick commands:"
echo "  - Reload: Press 'R' twice"
echo "  - Debug menu: Shake device or press Cmd+M"
echo "  - View Metro logs: tail -f /tmp/metro-bundler.log"
echo "  - Stop Metro: kill $METRO_PID"
echo ""
echo "🐛 Debug tips:"
echo "  - React Native logs: npx react-native log-android"
echo "  - Android logs: adb logcat | grep ReactNative"
echo "  - Chrome DevTools: Shake → Debug JS Remotely"
echo ""
echo "Happy Coding! 🎉"

