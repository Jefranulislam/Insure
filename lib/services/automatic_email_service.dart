import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AutomaticEmailService {
  // EmailJS configuration for client-side email sending
  static const String _emailJSUrl =
      'https://api.emailjs.com/api/v1.0/email/send';
  static const String _serviceId = 'insureso'; // Your actual service ID
  static const String _templateId =
      'template_yacl09c'; // Your actual template ID
  static const String _publicKey =
      'xeQh_Tvg5b6bjCux1'; // Your actual public key

  /// Send automatic email using EmailJS (works with Spark plan)
  static Future<bool> sendAutomaticClaimEmail({
    required String manufacturerEmail,
    required String brandName,
    required String productName,
    required String claimNumber,
    required String issueType,
    required String issueTitle,
    required String description,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user found');
        return false;
      }

      final customerName = user.displayName ?? 'Customer';
      final customerEmail = user.email ?? '';

      print(
        '🚀 Sending automatic email via EmailJS to $brandName at $manufacturerEmail',
      );

      // Prepare email data for EmailJS
      final emailData = {
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'template_params': {
          'to_email': manufacturerEmail,
          'to_name': '$brandName Support Team',
          'from_name': customerName,
          'from_email': customerEmail,
          'subject': 'Warranty Claim: $productName - Claim #$claimNumber',
          'brand_name': brandName,
          'product_name': productName,
          'claim_number': claimNumber,
          'issue_type': issueType,
          'issue_title': issueTitle,
          'description': description,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'submission_date': DateTime.now().toLocal().toString().split('.')[0],
        },
      };

      // Send POST request to EmailJS
      final response = await http.post(
        Uri.parse(_emailJSUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(emailData),
      );

      if (response.statusCode == 200) {
        print('✅ Automatic email sent successfully to $brandName');
        return true;
      } else {
        print(
          '❌ Failed to send automatic email. Status: ${response.statusCode}',
        );
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending automatic email: $e');
      return false;
    }
  }

  /// Fallback: Log email details for manual processing
  static Future<void> logEmailForManualProcessing({
    required String manufacturerEmail,
    required String brandName,
    required String productName,
    required String claimNumber,
    required String issueType,
    required String issueTitle,
    required String description,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final customerName = user?.displayName ?? 'Customer';
    final customerEmail = user?.email ?? '';

    final emailLog =
        '''
===============================
AUTOMATIC EMAIL LOG
===============================
Timestamp: ${DateTime.now().toLocal()}
To: $manufacturerEmail
Brand: $brandName
Product: $productName
Claim: $claimNumber
Customer: $customerName ($customerEmail)
Issue: $issueType - $issueTitle
Description: $description
===============================
    ''';

    print(emailLog);
  }

  /// Check if automatic email service is configured
  static bool isAutomaticEmailConfigured() {
    return _serviceId != 'YOUR_EMAILJS_SERVICE_ID' &&
        _templateId != 'YOUR_EMAILJS_TEMPLATE_ID' &&
        _publicKey != 'YOUR_EMAILJS_PUBLIC_KEY' &&
        _serviceId.isNotEmpty &&
        _templateId.isNotEmpty &&
        _publicKey.isNotEmpty;
  }

  /// Alternative: Send warranty expiry reminder (placeholder for EmailJS implementation)
  static Future<bool> sendExpiryReminder({
    required String userEmail,
    required String productName,
    required String brandName,
    required int daysLeft,
    required DateTime expiryDate,
  }) async {
    try {
      print(
        '📅 Sending expiry reminder for $productName ($daysLeft days left)',
      );

      // You can implement this using EmailJS similar to sendAutomaticClaimEmail
      // For now, just log the reminder
      print('✅ Expiry reminder logged for $productName');
      return true;
    } catch (e) {
      print('❌ Error sending expiry reminder: $e');
      return false;
    }
  }
}
