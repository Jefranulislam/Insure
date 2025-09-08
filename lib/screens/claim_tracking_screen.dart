import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/manufacturer_email_service.dart';

class ClaimTrackingScreen extends StatefulWidget {
  @override
  _ClaimTrackingScreenState createState() => _ClaimTrackingScreenState();
}

class _ClaimTrackingScreenState extends State<ClaimTrackingScreen> {
  List<DocumentSnapshot> claims = [];
  bool isLoading = true;
  String? errorMessage;
  String? warrantyId;
  String? productName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        warrantyId = arguments['warrantyId'];
        productName = arguments['productName'];
      }
      _loadClaims();
    });
  }

  Future<void> _loadClaims() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          errorMessage = 'User not authenticated';
          isLoading = false;
        });
        return;
      }

      // Build query based on warranty ID if provided
      Query query = FirebaseFirestore.instance
          .collection('warranty_claims')
          .where('userId', isEqualTo: currentUser.uid);

      // Add warranty ID filter if tracking specific product claims
      if (warrantyId != null) {
        query = query.where('warrantyId', isEqualTo: warrantyId);
      }

      final querySnapshot = await query.get();

      // Sort manually by claimDate
      final sortedClaims = querySnapshot.docs.toList();
      sortedClaims.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aDate = aData['claimDate'] as Timestamp?;
        final bDate = bData['claimDate'] as Timestamp?;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate); // Newest first
      });

      setState(() {
        claims = sortedClaims;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading claims: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _sendEmailToManufacturer(Map<String, dynamic> claim) async {
    try {
      final brand = claim['brand'] ?? '';
      final email = ManufacturerEmailService.getManufacturerEmail(brand);

      if (email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ No email found for $brand'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final productName = claim['productName'] ?? 'Product';
      final claimType = claim['claimType'] ?? 'Warranty Claim';
      final description = claim['description'] ?? '';
      final claimId = claim['claimId'] ?? '';

      final subject = Uri.encodeComponent(
        'Warranty Claim: $productName - Claim #$claimId',
      );
      final body = Uri.encodeComponent('''
Dear $brand Support Team,

I am writing to follow up on my warranty claim for the following product:

Product: $productName
Brand: $brand
Claim ID: $claimId
Claim Type: $claimType

Description:
$description

Please provide an update on the status of this claim.

Thank you for your assistance.

Best regards,
${FirebaseAuth.instance.currentUser?.displayName ?? 'Customer'}
${FirebaseAuth.instance.currentUser?.email ?? ''}
      ''');

      final emailUri = Uri.parse('mailto:$email?subject=$subject&body=$body');

      try {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(
            emailUri,
            mode: LaunchMode.externalApplication, // Force external app
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Email client opened for $brand'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Fallback: try Gmail or show manual options
          final gmailUri = Uri.parse(
            'googlegmail://co?to=$email&subject=$subject&body=$body',
          );
          if (await canLaunchUrl(gmailUri)) {
            await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Gmail app opened for $brand'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Could not open email client. Email: $email'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Copy Email',
                  textColor: Colors.white,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: email));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📋 Email address copied!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ),
            );
          }
        }
      } catch (e) {
        print('❌ Error launching email: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Email error. Contact: $email'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Copy',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: email));
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          warrantyId != null
              ? 'Claims: ${productName ?? 'Product'}'
              : 'All Claims',
          style: TextStyle(color: Color.fromARGB(255, 68, 68, 68)),
        ),
        backgroundColor: Color(0xFFF0F4F6),
        iconTheme: IconThemeData(color: Color.fromARGB(255, 68, 68, 68)),
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadClaims),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading claims...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error Loading Claims',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadClaims, child: Text('Retry')),
          ],
        ),
      );
    }

    if (claims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            SizedBox(height: 20),
            Text(
              'No Claims Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Warranty claims you submit will appear here',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 68, 68, 68),
              ),
              child: Text('Go Back', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: claims.length,
      itemBuilder: (context, index) {
        final claimData = claims[index].data() as Map<String, dynamic>;
        return _buildClaimCard(claimData);
      },
    );
  }

  Widget _buildClaimCard(Map<String, dynamic> claim) {
    final status = claim['status'] ?? 'submitted';
    final productName = claim['productName'] ?? 'Unknown Product';
    final brand = claim['brand'] ?? '';
    final claimDate = (claim['claimDate'] as Timestamp?)?.toDate();
    final companyEmail = claim['companyEmail'] ?? '';
    final claimNumber = claim['claimNumber'] ?? '';

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'submitted':
        statusColor = Colors.blue;
        statusIcon = Icons.send;
        break;
      case 'acknowledged':
        statusColor = Colors.orange;
        statusIcon = Icons.mark_email_read;
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (brand.isNotEmpty)
                        Text(
                          brand,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            if (claimNumber.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Claim #$claimNumber',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],

            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  claimDate != null
                      ? '${claimDate.day}/${claimDate.month}/${claimDate.year}'
                      : 'Unknown date',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            if (companyEmail.isNotEmpty) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      companyEmail,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _sendEmailToManufacturer(claim),
                  icon: Icon(Icons.email, size: 16),
                  label: Text('Contact $brand'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
