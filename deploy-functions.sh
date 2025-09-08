#!/bin/bash

# Firebase Functions Deployment Script for INSURE App
echo "🚀 Starting Firebase Functions deployment for INSURE app..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it with:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase. Please run:"
    echo "firebase login"
    exit 1
fi

# Navigate to functions directory
cd functions

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Navigate back to root
cd ..

# Deploy functions
echo "🔥 Deploying Firebase Functions..."
firebase deploy --only functions

if [ $? -eq 0 ]; then
    echo "✅ Firebase Functions deployed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Configure Gmail SMTP credentials:"
    echo "   firebase functions:config:set gmail.email=\"your-email@gmail.com\""
    echo "   firebase functions:config:set gmail.password=\"your-app-password\""
    echo ""
    echo "2. Redeploy after setting credentials:"
    echo "   firebase deploy --only functions"
    echo ""
    echo "3. Test the automatic email functionality in your app"
else
    echo "❌ Deployment failed. Check the error messages above."
    exit 1
fi
