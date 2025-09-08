# Automatic Email Configuration Guide

## 🚀 Setting up Automatic Background Email Sending

The app now supports **automatic email sending** in the background when users submit warranty claims. Here's how to configure it:

### Option 1: EmailJS (Recommended - Free & Easy)

1. **Create EmailJS Account:**

   - Go to [https://www.emailjs.com/](https://www.emailjs.com/)
   - Sign up for a free account (300 emails/month)

2. **Set up Email Service:**

   - Add your email service (Gmail, Outlook, etc.)
   - Create a new email template for warranty claims

3. **Configure the App:**

   - Open `lib/services/automatic_email_service.dart`
   - Replace `YOUR_EMAILJS_PUBLIC_KEY` with your actual EmailJS public key
   - Update `service_insure_app` and `template_warranty_claim` with your IDs

4. **Email Template Variables:**
   ```
   {{to_email}} - Manufacturer email
   {{brand_name}} - Brand name
   {{product_name}} - Product name
   {{claim_number}} - Claim number
   {{issue_type}} - Type of issue
   {{issue_title}} - Issue title
   {{description}} - Issue description
   {{customer_name}} - Customer name
   {{customer_email}} - Customer email
   {{submission_date}} - When claim was submitted
   ```

### Option 2: Webhook Service

1. **Set up Webhook:**

   - Use services like Zapier, Make.com, or custom webhook
   - Configure to receive POST requests with email data

2. **Update Configuration:**
   - In `automatic_email_service.dart`, update `YOUR_WEBHOOK_URL_HERE`
   - Ensure your webhook can send emails to manufacturers

### Option 3: Firebase Functions (Advanced)

1. **Create Firebase Function:**

   ```javascript
   exports.sendWarrantyEmail = functions.https.onCall(async (data, context) => {
     // Send email using SendGrid, Nodemailer, etc.
   });
   ```

2. **Call from Flutter:**
   ```dart
   await FirebaseFunctions.instance
     .httpsCallable('sendWarrantyEmail')
     .call(emailData);
   ```

## 🔧 How It Works

1. **User submits claim** → App saves to Firestore
2. **Automatic email attempt** → Tries to send email in background
3. **Success**: Shows "✅ Email automatically sent"
4. **Failure**: Falls back to manual email client opening

## 📧 Benefits of Automatic Email

- ✅ **Seamless UX**: No need to open email apps
- ✅ **Guaranteed delivery**: Emails sent reliably
- ✅ **Professional formatting**: Consistent email templates
- ✅ **Background processing**: No user interaction required
- ✅ **Fallback support**: Manual email if automatic fails

## 🛠️ Configuration Status

Currently configured for **manual email** (opens email client).
To enable automatic email, update the configuration in `automatic_email_service.dart`.

## 📱 Mobile vs Web

- **Mobile**: Automatic email works great
- **Web**: Perfect for background email sending
- **Fallback**: Manual email client opens if automatic fails

## 🔒 Security Notes

- Email credentials are not stored in the app
- Uses secure email services (EmailJS, webhooks)
- No direct SMTP credentials in client code
- Manufacturer emails are pre-validated
