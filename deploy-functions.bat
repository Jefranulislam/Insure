@echo off
REM Firebase Functions Deployment Script for INSURE App (Windows)
echo 🚀 Starting Firebase Functions deployment for INSURE app...

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Firebase CLI not found. Please install it with:
    echo npm install -g firebase-tools
    exit /b 1
)

REM Check if user is logged in
firebase projects:list >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Not logged in to Firebase. Please run:
    echo firebase login
    exit /b 1
)

REM Navigate to functions directory
cd functions

REM Install dependencies
echo 📦 Installing dependencies...
npm install

REM Navigate back to root
cd ..

REM Deploy functions
echo 🔥 Deploying Firebase Functions...
firebase deploy --only functions

if %errorlevel% equ 0 (
    echo ✅ Firebase Functions deployed successfully!
    echo.
    echo Next steps:
    echo 1. Configure Gmail SMTP credentials:
    echo    firebase functions:config:set gmail.email="your-email@gmail.com"
    echo    firebase functions:config:set gmail.password="your-app-password"
    echo.
    echo 2. Redeploy after setting credentials:
    echo    firebase deploy --only functions
    echo.
    echo 3. Test the automatic email functionality in your app
) else (
    echo ❌ Deployment failed. Check the error messages above.
    exit /b 1
)
