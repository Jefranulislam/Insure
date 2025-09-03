# INSURE - Never Lose a Warranty Again

A Flutter application that helps users manage and track their product warranties with Firebase integration.

![INSURE App](assets/images/app_preview.png)

## 🚀 Features

- **Google Authentication** - Secure sign-in with your Google account
- **Warranty Management** - Add, view, and track all your product warranties
- **Photo Upload** - Attach warranty cards, receipts, and product images
- **Smart Notifications** - Get reminded before warranties expire
- **Cross-Platform** - Works on Web, Android, iOS, Windows, and macOS
- **Cloud Storage** - All data securely stored with Firebase Firestore

## 📱 Screenshots

[Add screenshots of your app here]

## 🛠️ Technologies Used

- **Flutter** - Cross-platform mobile framework
- **Firebase Authentication** - Secure user authentication
- **Cloud Firestore** - NoSQL database for storing warranty data
- **Firebase Storage** - Cloud storage for images
- **Google Sign-In** - OAuth authentication

## 🏗️ Installation

### Prerequisites
- Flutter SDK (>=3.9.0)
- Firebase project setup
- Git

### Clone and Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/insure-app.git
cd insure-app

# Install dependencies
flutter pub get

# Configure Firebase
# 1. Create a new Firebase project at https://console.firebase.google.com
# 2. Enable Authentication (Google Sign-In)
# 3. Create Firestore Database
# 4. Replace lib/firebase_options.dart with your configuration

# Run the app
flutter run
```

## 🔧 Firebase Setup

1. **Create Firebase Project**: Go to [Firebase Console](https://console.firebase.google.com)
2. **Enable Authentication**: 
   - Go to Authentication → Sign-in method
   - Enable Google provider
3. **Create Firestore Database**:
   - Go to Firestore Database → Create database
   - Start in test mode (update rules for production)
4. **Update Configuration**:
   - Replace the values in `lib/firebase_options.dart`
   - Add your `google-services.json` to `android/app/`

## 🌐 Web Deployment

### Deploy to Firebase Hosting

```bash
# Build for web
flutter build web

# Install Firebase CLI
npm install -g firebase-tools

# Login and initialize
firebase login
firebase init hosting

# Deploy
firebase deploy
```

### Deploy to GitHub Pages

```bash
# Build for web
flutter build web --base-href "/insure-app/"

# Copy build to docs folder (or use gh-pages branch)
cp -r build/web/* docs/
```

## 📱 Mobile App Deployment

### Android (Google Play Store)

```bash
# Build APK
flutter build apk --release

# Or build App Bundle (recommended)
flutter build appbundle --release
```

### iOS (App Store)

```bash
# Build for iOS
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/YOUR_USERNAME/insure-app/issues) page
2. Create a new issue if needed
3. Contact: your.email@example.com

## 🎯 Roadmap

- [ ] Push notifications for warranty expiry
- [ ] Barcode scanning for quick product entry
- [ ] Export warranty data to PDF
- [ ] Dark mode support
- [ ] Offline mode with sync

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Contributors and users of this app

---

Made with ❤️ by [Your Name]

![INSURE Logo](assets/images/logo.png)

## 📱 About INSURE

INSURE is a comprehensive warranty management mobile application built with Flutter and Firebase. It helps users keep track of all their product warranties in one secure, cloud-based platform.

**Tagline**: "Never Lose a Warranty Again"

## ✨ Key Features

- **📸 Scan & Store**: Take photos of warranty cards, receipts, and products
- **🔔 Smart Notifications**: Get reminded before warranties expire
- **☁️ Cloud Backup**: Secure Firebase cloud storage
- **📧 Direct Claims**: Submit warranty claims directly from the app
- **🔍 Quick Search**: Find any warranty instantly
- **📂 Organization**: Categorize products for easy management
- **🌐 Multi-platform**: Works on iOS, Android, and Web

## 🏗️ App Architecture

### 9 Main Screens:
1. **Welcome Screen** - App introduction and features
2. **Registration Screen** - Google Sign-in authentication
3. **Home Screen** - Recent warranties dashboard
4. **Add Product Screen** - Form to add new warranty
5. **All Products Screen** - Complete warranty list with filters
6. **Product Details Screen** - Detailed warranty information
7. **About Screen** - App information and contact details
8. **Claim Warranty Screen** - Submit warranty claims
9. **Search Functionality** - Integrated across multiple screens

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Authentication (Google Sign-in)
  - Firestore Database
  - Cloud Storage
- **State Management**: StatefulWidget/setState
- **Navigation**: Named Routes

## 📋 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.7.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.4.6
  firebase_storage: ^12.3.7
  
  # Authentication
  google_sign_in: ^6.2.1
  
  # Image handling
  image_picker: ^1.1.2
  
  # Utilities
  intl: ^0.19.0
  cupertino_icons: ^1.0.8
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Firebase project setup
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd insure_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Google Sign-in)
   - Create Firestore Database
   - Enable Cloud Storage
   - Download configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
   - Update `lib/firebase_options.dart` with your project credentials

4. **Update Firebase Configuration**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for Flutter
   flutterfire configure
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Flow

```
Welcome Screen → Registration (Google Sign-in) → Home Screen
     ↓
Add Product ← → All Products ← → Product Details ← → Claim Warranty
     ↓
About Screen
```

## 🗄️ Database Structure

### Firestore Collections

#### `warranties`
```json
{
  "userId": "string",
  "productName": "string",
  "brand": "string",
  "category": "string",
  "serialNumber": "string",
  "price": "number",
  "purchaseDate": "timestamp",
  "warrantyMonths": "number",
  "expiryDate": "timestamp",
  "notes": "string",
  "imageUrl": "string",
  "warrantyCardUrl": "string",
  "receiptUrl": "string",
  "createdAt": "timestamp",
  "isActive": "boolean"
}
```

#### `warranty_claims`
```json
{
  "warrantyId": "string",
  "userId": "string",
  "productName": "string",
  "brand": "string",
  "issueType": "string",
  "issueTitle": "string",
  "description": "string",
  "status": "string",
  "claimNumber": "string",
  "createdAt": "timestamp"
}
```

## 🎨 UI/UX Features

- **Material Design 3** principles
- **Responsive Design** for different screen sizes
- **Dark/Light Theme** support
- **Custom Color Scheme** (Primary: #1E88E5)
- **Intuitive Navigation** with bottom navigation and floating action buttons
- **Status Indicators** for warranty expiry (Active/Expiring Soon/Expired)
- **Image Gallery** for warranty documents
- **Search and Filter** functionality

## 🔒 Security Features

- **Firebase Authentication** with Google Sign-in
- **User-specific Data** isolation
- **Secure Cloud Storage** for images
- **Input Validation** and sanitization
- **Privacy Policy** and Terms of Service

## 📈 Future Enhancements

- [ ] Push notifications for warranty expiry
- [ ] OCR for automatic warranty card reading
- [ ] Export data functionality
- [ ] Multi-language support
- [ ] Dark theme toggle
- [ ] Biometric authentication
- [ ] Integration with manufacturer APIs
- [ ] Warranty reminder scheduling
- [ ] PDF generation for claims
- [ ] Social sharing features

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

- **Email**: support@insureapp.com
- **Website**: www.insureapp.com
- **Developer**: [Your Name]

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend infrastructure
- Material Design for UI guidelines
- Open source community for various packages

---

**INSURE - Never Lose a Warranty Again** ⚡
