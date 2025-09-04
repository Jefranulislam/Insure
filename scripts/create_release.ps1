# INSURE App Release Script for Windows
# Run this script to create a new release

param(
    [Parameter(Mandatory=$true)]
    [string]$Version
)

Write-Host "🚀 Creating release $Version for INSURE App" -ForegroundColor Green

# Build the app
Write-Host "📱 Building Android APK..." -ForegroundColor Yellow
flutter build apk --release

Write-Host "📦 Building App Bundle..." -ForegroundColor Yellow
flutter build appbundle --release

Write-Host "🌐 Building Web version..." -ForegroundColor Yellow
flutter build web --release

# Create git tag
Write-Host "🏷️ Creating git tag..." -ForegroundColor Yellow
git tag $Version
git push origin $Version

Write-Host "✅ Release $Version created!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Go to https://github.com/YOUR_USERNAME/insure-app/releases"
Write-Host "2. Click 'Create a new release'"
Write-Host "3. Select tag: $Version"
Write-Host "4. Upload build/app/outputs/flutter-apk/app-release.apk"
Write-Host "5. Add release notes and publish"
Write-Host ""
Write-Host "📁 Built files location:" -ForegroundColor Cyan
Write-Host "- APK: build/app/outputs/flutter-apk/app-release.apk"
Write-Host "- App Bundle: build/app/outputs/bundle/release/app-release.aab"
Write-Host "- Web: build/web/"

# Open file explorer to the APK location
Write-Host "📂 Opening APK location..." -ForegroundColor Yellow
explorer "build\app\outputs\flutter-apk"
