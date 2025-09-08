import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/manufacturer_email_service.dart';
import '../services/automatic_email_service.dart';

class ClaimWarrantyScreen extends StatefulWidget {
  @override
  _ClaimWarrantyScreenState createState() => _ClaimWarrantyScreenState();
}

class _ClaimWarrantyScreenState extends State<ClaimWarrantyScreen> {
  String? warrantyId;
  Map<String, dynamic>? warrantyData;
  bool isLoading = true;
  bool isSubmitting = false;

  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedIssueType = 'Defect';
  final List<String> _issueTypes = [
    'Defect',
    'Malfunction',
    'Damage',
    'Not Working',
    'Poor Performance',
    'Other',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    warrantyId = ModalRoute.of(context)?.settings.arguments as String?;
    _loadWarrantyData();
  }

  Future<void> _loadWarrantyData() async {
    if (warrantyId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('warranties')
          .doc(warrantyId)
          .get();

      if (doc.exists) {
        setState(() {
          warrantyData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading warranty details')));
    }
  }

  Future<void> _sendEmailToManufacturer(String claimNumber) async {
    try {
      final brand = warrantyData!['brand'] ?? '';
      final email = ManufacturerEmailService.getManufacturerEmail(brand);

      if (email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ No email found for $brand. Please contact them directly.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      final productName = warrantyData!['productName'] ?? 'Product';
      final user = FirebaseAuth.instance.currentUser;
      final customerName = user?.displayName ?? 'Customer';
      final customerEmail = user?.email ?? '';

      final subject = Uri.encodeComponent(
        'Warranty Claim: $productName - Claim #$claimNumber',
      );
      final body = Uri.encodeComponent('''
Dear $brand Support Team,

I am submitting a warranty claim for the following product:

Product Name: $productName
Brand: $brand
Claim Number: $claimNumber
Issue Type: $_selectedIssueType
Issue Title: ${_issueController.text.trim()}

Description:
${_descriptionController.text.trim()}

Customer Information:
Name: $customerName
Email: $customerEmail

Please review this claim and provide an update on the warranty coverage and next steps.

Thank you for your assistance.

Best regards,
$customerName
      ''');

      final emailUri = Uri.parse('mailto:$email?subject=$subject&body=$body');

      try {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(
            emailUri,
            mode: LaunchMode.externalApplication, // Force external app
          );
          print('✅ Email client opened for $brand at $email');
        } else {
          // Fallback: try launching with different parameters
          print('❌ Standard email launch failed, trying fallback...');

          // Try launching Gmail directly if available
          final gmailUri = Uri.parse(
            'googlegmail://co?to=$email&subject=$subject&body=$body',
          );
          if (await canLaunchUrl(gmailUri)) {
            await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
            print('✅ Gmail app opened for $brand at $email');
          } else {
            // Show manual email info
            _showManualEmailDialog(email, subject, body, brand);
          }
        }
      } catch (e) {
        print('❌ Error launching email: $e');
        _showManualEmailDialog(email, subject, body, brand);
      }
    } catch (e) {
      print('❌ Error sending email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening email client. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showManualEmailDialog(
    String email,
    String subject,
    String body,
    String brand,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.email, color: Color(0xFF1E88E5)),
              SizedBox(width: 8),
              Text('Email Details'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Could not open email client automatically. Please send an email manually with these details:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                _buildEmailDetailRow('To:', email),
                _buildEmailDetailRow('Subject:', Uri.decodeComponent(subject)),
                SizedBox(height: 8),
                Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    Uri.decodeComponent(body),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Try to copy email to clipboard
                _copyEmailToClipboard(email, subject, body);
              },
              child: Text('Copy Email'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmailDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: SelectableText(value, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _copyEmailToClipboard(String email, String subject, String body) {
    final emailContent =
        '''
To: $email
Subject: ${Uri.decodeComponent(subject)}

${Uri.decodeComponent(body)}
''';

    Clipboard.setData(ClipboardData(text: emailContent));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📋 Email details copied to clipboard!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Open Email App',
          textColor: Colors.white,
          onPressed: () {
            // Try to open any email app
            launchUrl(Uri.parse('mailto:'));
          },
        ),
      ),
    );
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      // Get manufacturer email
      final brand = warrantyData!['brand'] ?? '';
      final companyEmail =
          ManufacturerEmailService.getManufacturerEmail(brand) ?? '';

      // Generate claim number
      final claimNumber = 'CLM${DateTime.now().millisecondsSinceEpoch}';

      // Create a warranty claim document
      await FirebaseFirestore.instance.collection('warranty_claims').add({
        'warrantyId': warrantyId,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'productName': warrantyData!['productName'],
        'brand': brand,
        'companyEmail': companyEmail,
        'issueType': _selectedIssueType,
        'issueTitle': _issueController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': 'submitted',
        'claimDate': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'claimNumber': claimNumber,
      });

      // Try automatic email sending first
      bool automaticEmailSent = false;
      if (companyEmail.isNotEmpty &&
          AutomaticEmailService.isAutomaticEmailConfigured()) {
        print('🚀 Attempting automatic email to $brand...');
        automaticEmailSent =
            await AutomaticEmailService.sendAutomaticClaimEmail(
              manufacturerEmail: companyEmail,
              brandName: brand,
              productName: warrantyData!['productName'] ?? '',
              claimNumber: claimNumber,
              issueType: _selectedIssueType,
              issueTitle: _issueController.text.trim(),
              description: _descriptionController.text.trim(),
            );
      }

      // Fallback: Manual email if automatic failed or not configured
      if (!automaticEmailSent) {
        print(
          '📧 Automatic email failed/not configured, opening manual email...',
        );
        await _sendEmailToManufacturer(claimNumber);
      }

      // Show success dialog with email confirmation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('✅ Claim Submitted Successfully!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Claim Number: $claimNumber'),
              SizedBox(height: 8),
              if (automaticEmailSent) ...[
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text('Email automatically sent to $brand'),
                  ],
                ),
                Text(
                  '($companyEmail)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(Icons.email, color: Colors.blue, size: 16),
                    SizedBox(width: 4),
                    Text('Email client opened for $brand'),
                  ],
                ),
                if (companyEmail.isNotEmpty)
                  Text(
                    '($companyEmail)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
              SizedBox(height: 16),
              Text(
                automaticEmailSent
                    ? 'The manufacturer has been automatically notified about your warranty claim.'
                    : 'Your email client should have opened automatically. If not, you can resend the email from the claim tracking screen.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('View Claims'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting claim: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Claim Warranty', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1E88E5),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (warrantyData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Claim Warranty', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1E88E5),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Warranty not found',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final productName = warrantyData!['productName'] ?? '';
    final brand = warrantyData!['brand'] ?? '';

    // Safe timestamp handling
    DateTime expiryDate;
    try {
      final expiryTimestamp = warrantyData!['expiryDate'];
      expiryDate = expiryTimestamp != null
          ? (expiryTimestamp as Timestamp).toDate()
          : DateTime.now().add(Duration(days: 365));
    } catch (e) {
      print('❌ Error parsing expiryDate in claim warranty: $e');
      expiryDate = DateTime.now().add(Duration(days: 365));
    }

    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    final isExpired = daysLeft < 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Claim Warranty', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E88E5),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Information Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory, color: Color(0xFF1E88E5)),
                          SizedBox(width: 8),
                          Text(
                            'Product Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        productName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        brand,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isExpired
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isExpired
                              ? 'Warranty Expired'
                              : 'Warranty Active - $daysLeft days left',
                          style: TextStyle(
                            color: isExpired ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isExpired)
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'This warranty has expired, but you can still submit a claim. Some manufacturers may honor expired warranties.',
                                    style: TextStyle(
                                      color: Colors.orange[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Claim Form
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.report_problem, color: Color(0xFF1E88E5)),
                          SizedBox(width: 8),
                          Text(
                            'Warranty Claim Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Issue Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedIssueType,
                        decoration: InputDecoration(
                          labelText: 'Issue Type *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _issueTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedIssueType = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Issue Title
                      TextFormField(
                        controller: _issueController,
                        decoration: InputDecoration(
                          labelText: 'Issue Title *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                          hintText: 'Brief description of the issue',
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return 'Please enter an issue title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Detailed Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Detailed Description *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          hintText:
                              'Provide a detailed description of the problem, when it occurred, and any steps you\'ve taken...',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return 'Please provide a detailed description';
                          }
                          if (value!.length < 20) {
                            return 'Description must be at least 20 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Information Card
              Card(
                color: Colors.blue.withOpacity(0.05),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Color(0xFF1E88E5)),
                          SizedBox(width: 8),
                          Text(
                            'What happens next?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildInfoStep(
                        '1',
                        'Your claim is submitted with a unique claim number',
                      ),
                      _buildInfoStep(
                        '2',
                        'We\'ll review your claim and contact you within 2-3 business days',
                      ),
                      _buildInfoStep(
                        '3',
                        'You may be asked to provide additional documentation',
                      ),
                      _buildInfoStep(
                        '4',
                        'Once approved, repair/replacement instructions will be provided',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E88E5),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Submitting...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Submit Warranty Claim',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16),

              // Disclaimer
              Text(
                'By submitting this claim, you agree that the information provided is accurate and complete. False claims may result in rejection.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Color(0xFF1E88E5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _issueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
