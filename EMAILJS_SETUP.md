# EmailJS Setup Guide for INSURE App (Spark Plan Compatible)

## 🚀 Overview

Since you're using Firebase Spark (free) plan, we've configured your app to use **EmailJS** for automatic email sending. EmailJS is a client-side email service that works perfectly with the free plan.

## ✅ What's Already Done

- ✅ EmailJS integration in `automatic_email_service.dart`
- ✅ Client-side email sending (no server required)
- ✅ Compatible with Firebase Spark plan
- ✅ Same claim warranty functionality

## 📧 EmailJS Setup (5 minutes)

### Step 1: Create EmailJS Account

1. Go to [EmailJS.com](https://www.emailjs.com/)
2. Sign up for a free account (300 emails/month free)
3. Verify your email address

### Step 2: Create Email Service

1. In EmailJS dashboard, click **"Add New Service"**
2. Choose **Gmail** (recommended) or your preferred provider
3. Connect your Gmail account:
   - Allow EmailJS to access your Gmail
   - This will be used to send emails

### Step 3: Create Email Template

1. Go to **"Email Templates"** → **"Create New Template"**
2. Use this template:

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 20px;
      }
      .header {
        background-color: #2196f3;
        color: white;
        padding: 20px;
        text-align: center;
      }
      .content {
        padding: 20px;
        border: 1px solid #ddd;
      }
      .claim-info {
        background-color: #f5f5f5;
        padding: 15px;
        margin: 10px 0;
      }
      .footer {
        text-align: center;
        color: #666;
        margin-top: 20px;
      }
    </style>
  </head>
  <body>
    <div class="header">
      <h1>🛡️ INSURE - Warranty Claim</h1>
    </div>

    <div class="content">
      <h2>Dear {{brand_name}} Support Team,</h2>

      <p>A warranty claim has been submitted through the INSURE app:</p>

      <div class="claim-info">
        <h3>📦 Product Details</h3>
        <strong>Product:</strong> {{product_name}}<br />
        <strong>Brand:</strong> {{brand_name}}<br />
        <strong>Claim Number:</strong> {{claim_number}}
      </div>

      <div class="claim-info">
        <h3>⚠️ Issue Information</h3>
        <strong>Issue Type:</strong> {{issue_type}}<br />
        <strong>Issue Title:</strong> {{issue_title}}<br />
        <strong>Description:</strong> {{description}}
      </div>

      <div class="claim-info">
        <h3>👤 Customer Information</h3>
        <strong>Name:</strong> {{customer_name}}<br />
        <strong>Email:</strong> {{customer_email}}<br />
        <strong>Submission Date:</strong> {{submission_date}}
      </div>

      <p>
        Please review this claim and provide an update on warranty coverage and
        next steps.
      </p>

      <p>
        <strong>Reply to this email</strong> to respond directly to the
        customer.
      </p>
    </div>

    <div class="footer">
      <p>
        This email was sent automatically from the INSURE warranty management
        app.
      </p>
      <p>🛡️ <strong>INSURE</strong> - Never Lose a Warranty Again</p>
    </div>
  </body>
</html>
```

3. Set these **Template Parameters**:
   - `to_email`, `brand_name`, `product_name`, `claim_number`
   - `issue_type`, `issue_title`, `description`
   - `customer_name`, `customer_email`, `submission_date`

### Step 4: Get Configuration Details

After setting up service and template, get these values:

1. **Service ID**: From your EmailJS service (e.g., `service_abc123`)
2. **Template ID**: From your template (e.g., `template_xyz789`)
3. **Public Key**: From Account → API Keys (e.g., `user_def456`)

### Step 5: Update Your App

Update the configuration in `lib/services/automatic_email_service.dart`:

```dart
// Replace these with your actual EmailJS values
static const String _serviceId = 'YOUR_SERVICE_ID_HERE';
static const String _templateId = 'YOUR_TEMPLATE_ID_HERE';
static const String _publicKey = 'YOUR_PUBLIC_KEY_HERE';
```

## 🎯 Example Configuration

```dart
static const String _serviceId = 'service_abc123';
static const String _templateId = 'template_xyz789';
static const String _publicKey = 'user_def456';
```

## 🧪 Testing

1. Build and run your app
2. Go to **Recent Warranties** → select a warranty → **Claim Warranty**
3. Fill out the claim form and submit
4. Check the console for success messages
5. Verify the email was sent to the manufacturer

## 💰 Cost Comparison

### EmailJS (Current Solution)

- ✅ **Free**: 300 emails/month
- ✅ **Paid**: $15/month for 1000 emails
- ✅ **Works with Spark plan**

### Firebase Functions (Alternative)

- ❌ **Requires Blaze plan**: Pay-as-you-go
- ✅ **Free tier**: 2M calls/month
- ✅ **More reliable**: Server-side sending

## 🔧 Troubleshooting

### Common Issues:

1. **"EmailJS not configured"** → Update the configuration constants
2. **"Failed to send email"** → Check EmailJS service setup
3. **"Template not found"** → Verify template ID is correct

### Debug Steps:

1. Check EmailJS dashboard for sent emails
2. Verify service and template are active
3. Check network connectivity
4. Review app console for error messages

## 🎉 You're All Set!

Once configured, your INSURE app will automatically:

- ✅ Send professional emails to manufacturers
- ✅ Include all warranty claim details
- ✅ Work with Firebase Spark (free) plan
- ✅ Provide cost-effective email automation

Your warranty claim emails will be sent automatically through EmailJS! 📧🚀
