# Firebase Functions Setup for INSURE App

## Overview

This Firebase Functions implementation provides automatic email sending functionality for warranty claims using nodemailer and Gmail SMTP.

## Setup Instructions

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Login to Firebase

```bash
firebase login
```

### 3. Initialize Firebase (if not already done)

```bash
firebase init functions
# Select your existing Firebase project
# Choose JavaScript
# Install dependencies with npm
```

### 4. Install Dependencies

```bash
cd functions
npm install
```

### 5. Configure Environment Variables

Set up Gmail SMTP credentials for automatic email sending:

```bash
firebase functions:config:set gmail.email="your-email@gmail.com"
firebase functions:config:set gmail.password="your-app-password"
```

**Important**: Use an App Password, not your regular Gmail password. To create an App Password:

1. Go to your Google Account settings
2. Security → 2-Step Verification (must be enabled)
3. App passwords → Generate password for "Mail"
4. Use this generated password

### 6. Deploy Functions

```bash
firebase deploy --only functions
```

### 7. Test the Function (Optional)

You can test the function using the Firebase console or by calling it from your Flutter app.

## Functions Available

### `sendWarrantyClaimEmail`

- **Purpose**: Send automatic emails to manufacturers when warranty claims are submitted
- **Trigger**: HTTPS Callable from Flutter app
- **Parameters**:
  - `manufacturerEmail`: Email address of the manufacturer
  - `brandName`: Brand name
  - `productName`: Product name
  - `claimNumber`: Unique claim number
  - `issueType`: Type of issue
  - `issueTitle`: Issue title
  - `description`: Detailed description
  - `customerName`: Customer's name
  - `customerEmail`: Customer's email

### `sendWarrantyExpiryReminder`

- **Purpose**: Send warranty expiry reminders to customers
- **Trigger**: HTTPS Callable or scheduled function
- **Parameters**:
  - `userEmail`: Customer's email
  - `productName`: Product name
  - `brandName`: Brand name
  - `daysLeft`: Days until expiry
  - `expiryDate`: Expiry date

## Security

- Functions are protected by Firebase Auth
- Only authenticated users can call the functions
- Email logs are stored in Firestore for audit purposes

## Troubleshooting

### Common Issues

1. **Authentication Error**: Make sure user is signed in before calling functions
2. **SMTP Error**: Verify Gmail credentials and App Password
3. **Deployment Error**: Check Firebase project permissions

### Logs

View function logs:

```bash
firebase functions:log
```

### Local Testing

Run functions locally:

```bash
cd functions
npm run serve
```

## Email Template

The functions use professional HTML email templates with:

- Company branding
- Structured warranty claim information
- Customer contact details
- Automatic CC to customer
- Professional formatting

## Cost Considerations

- Firebase Functions: Pay per invocation (free tier: 2M invocations/month)
- Gmail SMTP: Free for reasonable usage
- Firestore: Pay per read/write (free tier available)

## Support

For issues with Firebase Functions setup, refer to:

- [Firebase Functions Documentation](https://firebase.google.com/docs/functions)
- [Nodemailer Documentation](https://nodemailer.com/)
