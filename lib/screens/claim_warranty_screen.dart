import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
    'Other'
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading warranty details')),
      );
    }
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      isSubmitting = true;
    });

    try {
      // Create a warranty claim document
      await FirebaseFirestore.instance.collection('warranty_claims').add({
        'warrantyId': warrantyId,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'productName': warrantyData!['productName'],
        'brand': warrantyData!['brand'],
        'issueType': _selectedIssueType,
        'issueTitle': _issueController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': 'Submitted',
        'createdAt': Timestamp.now(),
        'claimNumber': 'CLM${DateTime.now().millisecondsSinceEpoch}',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Warranty claim submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
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
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final productName = warrantyData!['productName'] ?? '';
    final brand = warrantyData!['brand'] ?? '';
    final expiryDate = (warrantyData!['expiryDate'] as Timestamp).toDate();
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
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isExpired ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
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
                                Icon(Icons.warning, color: Colors.orange, size: 20),
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
                          hintText: 'Provide a detailed description of the problem, when it occurred, and any steps you\'ve taken...',
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
                      _buildInfoStep('1', 'Your claim is submitted with a unique claim number'),
                      _buildInfoStep('2', 'We\'ll review your claim and contact you within 2-3 business days'),
                      _buildInfoStep('3', 'You may be asked to provide additional documentation'),
                      _buildInfoStep('4', 'Once approved, repair/replacement instructions will be provided'),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
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
