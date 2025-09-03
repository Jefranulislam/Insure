#!/bin/bash

# INSURE App Setup Script

echo "🚀 Setting up INSURE App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    echo "Visit: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found"

# Check Flutter version
echo "📋 Checking Flutter doctor..."
flutter doctor

# Install dependencies  
echo "📦 Installing dependencies..."
flutter pub get

# Check for issues
echo "🔍 Analyzing code..."
flutter analyze

echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Follow FIREBASE_SETUP.md to configure Firebase"
echo "2. Run 'flutter run' to start the app"
echo "3. Enjoy your warranty management app!"
