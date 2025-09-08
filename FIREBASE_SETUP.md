# INSURE App - Firebase Functions Email Setup Guide

## 🎯 Overview

You've successfully implemented Firebase Functions for automatic email sending! This guide will help you complete the setup and start sending automatic warranty claim emails.

## ✅ What's Already Done

- ✅ Firebase Functions implementation (`functions/index.js`)
- ✅ Client-side integration (`automatic_email_service.dart`)
- ✅ Professional HTML email templates
- ✅ Claim warranty screen integration
- ✅ Dependencies added to `pubspec.yaml`
- ✅ Deployment scripts created

## 🚀 Quick Setup (5 minutes)

### Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase

```bash
firebase login
```

### Step 3: Deploy Functions

Run the deployment script:

**Windows:**

```bash
.\deploy-functions.bat
```

**Mac/Linux:**

```bash
chmod +x deploy-functions.sh
./deploy-functions.sh
```

### Step 4: Configure Gmail SMTP

Set up your Gmail credentials for sending emails:

```bash
firebase functions:config:set gmail.email="your-app-email@gmail.com"
firebase functions:config:set gmail.password="your-app-password"
```

> **⚠️ Important**: Use an App Password, not your regular Gmail password!

#### How to Create Gmail App Password:

1. Go to [Google Account settings](https://myaccount.google.com/)
2. Security → 2-Step Verification (enable if not already)
3. App passwords → Generate password for "Mail"
4. Use the generated 16-character password

### Step 5: Final Deployment

After setting credentials, deploy again:

```bash
firebase deploy --only functions
```

## 🧪 Testing

1. Open your INSURE app
2. Go to "Recent Warranties" → Select a warranty → "Claim Warranty"
3. Fill out the claim form and submit
4. Check the debug console for success messages
5. Verify the email was sent to the manufacturer and copied to your email

## 📧 Email Features

- **Professional Templates**: HTML emails with proper formatting
- **Automatic CC**: Customer receives a copy of every claim
- **Audit Trail**: All emails logged in Firestore
- **Error Handling**: Fallback logging if sending fails
- **Brand Recognition**: Includes INSURE app branding

## 🔧 Configuration Options

### Custom SMTP Provider (Optional)

If you prefer a different email provider (SendGrid, AWS SES, etc.), modify `functions/index.js`:

```javascript
const transporter = nodemailer.createTransporter({
  service: "SendGrid", // or your provider
  auth: {
    user: functions.config().sendgrid.user,
    pass: functions.config().sendgrid.apikey,
  },
});
```

### Email Template Customization

Edit the HTML template in `functions/index.js` around line 30-80 to customize:

- Company logo/branding
- Email styling
- Footer information
- Contact details

## 📊 Monitoring

View function logs:

```bash
firebase functions:log
```

Check email delivery status in Firebase Console → Functions → Logs

## 💰 Cost Estimate

- **Firebase Functions**: Free tier covers 2M invocations/month
- **Gmail SMTP**: Free for standard usage
- **Typical cost**: $0-5/month for most warranty apps

## 🆘 Troubleshooting

### Common Issues:

1. **"Gmail login failed"** → Check App Password setup
2. **"Function not found"** → Ensure functions are deployed
3. **"Authentication error"** → User must be signed in to app
4. **"Network error"** → Check Firebase project configuration

### Debug Steps:

1. Check Firebase console for function execution logs
2. Verify Gmail SMTP credentials
3. Test with a simple claim submission
4. Review error messages in app debug console

## 🎉 You're All Set!

Once configured, your INSURE app will automatically:

- Send professional emails to manufacturers
- Copy customers on all warranty claims
- Log all email activity for audit purposes
- Provide fallback error handling

The automatic email system is now enterprise-grade and reliable! 🚀
