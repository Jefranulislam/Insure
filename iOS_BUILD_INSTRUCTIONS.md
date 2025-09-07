# iOS Build Instructions for Insure App

## Prerequisites (Must be on macOS)

1. Install Xcode from Mac App Store
2. Install Flutter on macOS
3. Install CocoaPods: `sudo gem install cocoapods`

## Steps to Build iOS App

### 1. Setup Xcode

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 2. Install iOS dependencies

```bash
cd ios
pod install
cd ..
```

### 3. Open iOS project in Xcode (Optional - for configuration)

```bash
open ios/Runner.xcworkspace
```

### 4. Build for iOS Simulator (Testing)

```bash
flutter run -d ios
```

### 5. Build for Physical Device (Development)

```bash
flutter build ios --debug
```

### 6. Build for App Store Release

```bash
flutter build ios --release
```

## Important Notes

### Bundle Identifier

- Current: `com.example.insure` (needs to be changed)
- Should be: `com.yourcompany.insure` or similar
- Change in: `ios/Runner.xcodeproj/project.pbxproj`

### Firebase iOS Configuration

- You'll need to add `GoogleService-Info.plist` to the iOS project
- Download from Firebase Console > iOS app
- Add to `ios/Runner/` folder in Xcode

### Code Signing

- You'll need an Apple Developer Account ($99/year)
- Set up certificates and provisioning profiles in Xcode

## Current Project Status

✅ iOS folder structure is ready
✅ Info.plist is configured
✅ Firebase dependencies are included
✅ Image picker works cross-platform
✅ All Dart code is iOS-compatible

## What Works Out of the Box

- Firebase Authentication
- Firebase Firestore
- Firebase Storage
- Image picker (camera/gallery)
- All UI components

## Cloud Build Alternative

If you don't want to buy a Mac, consider:

- Codemagic (Flutter CI/CD) - has free tier
- GitHub Actions with macOS runner
- Rent a Mac in the cloud

## Web App (Current Solution)

Your app is now available as a web app at:
http://localhost:8080

This works on:

- Any computer browser
- iPhone/iPad Safari
- Android Chrome
- All mobile browsers

The web version has all the same features as the mobile apps!
