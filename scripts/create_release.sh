#!/bin/bash

# INSURE App Release Script
# Run this script to create a new release

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Usage: ./create_release.sh v1.0.0"
    exit 1
fi

echo "🚀 Creating release $VERSION for INSURE App"

# Build the app
echo "📱 Building Android APK..."
flutter build apk --release

echo "📦 Building App Bundle..."
flutter build appbundle --release

echo "🌐 Building Web version..."
flutter build web --release

# Create git tag
echo "🏷️ Creating git tag..."
git tag $VERSION
git push origin $VERSION

echo "✅ Release $VERSION created!"
echo ""
echo "📋 Next steps:"
echo "1. Go to https://github.com/YOUR_USERNAME/insure-app/releases"
echo "2. Click 'Create a new release'"
echo "3. Select tag: $VERSION"
echo "4. Upload build/app/outputs/flutter-apk/app-release.apk"
echo "5. Add release notes and publish"
echo ""
echo "📁 Built files location:"
echo "- APK: build/app/outputs/flutter-apk/app-release.apk"
echo "- App Bundle: build/app/outputs/bundle/release/app-release.aab"
echo "- Web: build/web/"
