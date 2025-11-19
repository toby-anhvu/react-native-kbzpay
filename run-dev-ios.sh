#!/bin/bash

# KBZPay iOS Development Runner
# Script này giúp chạy example app trên iOS nhanh chóng

set -e

echo "🚀 Starting KBZPay iOS Development Environment..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "package.json not found. Please run this script from the project root."
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

print_success "Xcode found"

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    print_error "CocoaPods is not installed."
    echo ""
    echo "Please install CocoaPods:"
    echo "  sudo gem install cocoapods"
    exit 1
fi

print_success "CocoaPods found"

# Step 1: Install root dependencies
print_step "Installing root dependencies..."
if [ -f "yarn.lock" ]; then
    yarn install
else
    npm install
fi
print_success "Root dependencies installed"

# Step 2: Navigate to example
cd example

# Step 3: Install example dependencies
print_step "Installing example dependencies..."
if [ -f "yarn.lock" ]; then
    yarn install
else
    npm install
fi
print_success "Example dependencies installed"

# Step 4: Install iOS Pods
print_step "Installing iOS Pods..."
cd ios

# Clean pods if needed
if [ "$1" == "--clean" ]; then
    print_warning "Cleaning pods..."
    rm -rf Pods Podfile.lock
fi

pod install

print_success "iOS Pods installed"

cd ..

# Step 5: Check for available simulators
print_step "Checking available iOS simulators..."
echo ""
xcrun simctl list devices available | grep -i "iphone"
echo ""

# Step 6: Run the app
print_step "Starting Metro bundler and iOS app..."
echo ""
print_warning "Make sure to:"
print_warning "1. Configure Info.plist with your app scheme"
print_warning "2. Update AppDelegate.swift to handle deep links"
print_warning "3. Install KBZPay app on your simulator/device"
echo ""

# Ask user which simulator to use
read -p "Enter simulator name (or press Enter for default): " SIMULATOR

if [ -z "$SIMULATOR" ]; then
    npx react-native run-ios
else
    npx react-native run-ios --simulator="$SIMULATOR"
fi

print_success "iOS app started successfully!"
echo ""
print_step "Next steps:"
echo "  1. Check logs in Xcode Console"
echo "  2. Test payment flow with KBZPay app"
echo "  3. Monitor deep link callbacks"
echo ""
echo "📱 Happy coding!"

