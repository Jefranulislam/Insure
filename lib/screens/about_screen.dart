import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('About Us', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E88E5),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo and Name
            Container(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF1E88E5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.security,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'INSURE',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Never Lose a Warranty Again',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            // Mission Statement
            _buildSection(
              'Our Mission',
              'INSURE is designed to help you keep track of all your product warranties in one secure place. Never worry about losing warranty cards or missing expiry dates again.',
            ),
            
            // Features Section
            _buildSection(
              'Key Features',
              null,
              child: Column(
                children: [
                  _buildFeatureItem(
                    Icons.camera_alt,
                    'Scan & Store',
                    'Take photos of warranty cards, receipts, and products',
                  ),
                  _buildFeatureItem(
                    Icons.notifications_active,
                    'Smart Reminders',
                    'Get notified before your warranties expire',
                  ),
                  _buildFeatureItem(
                    Icons.cloud_done,
                    'Cloud Backup',
                    'Your data is safely stored in the cloud',
                  ),
                  _buildFeatureItem(
                    Icons.email,
                    'Easy Claims',
                    'Contact support directly from the app',
                  ),
                  _buildFeatureItem(
                    Icons.search,
                    'Quick Search',
                    'Find any product warranty instantly',
                  ),
                  _buildFeatureItem(
                    Icons.category,
                    'Organization',
                    'Categorize products for easy management',
                  ),
                ],
              ),
            ),
            
            // Version and Credits
            _buildSection(
              'App Information',
              'Version 1.0.0\n\nDeveloped with ❤️ using Flutter\n\nSecure cloud storage powered by Firebase',
            ),
            
            // Contact Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildContactItem(Icons.email, 'support@insureapp.com'),
                  _buildContactItem(Icons.phone, '+1 (555) 123-4567'),
                  _buildContactItem(Icons.web, 'www.insureapp.com'),
                  
                  SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialButton(Icons.facebook, 'Facebook'),
                      _buildSocialButton(Icons.alternate_email, 'Twitter'),
                      _buildSocialButton(Icons.camera_alt, 'Instagram'),
                    ],
                  ),
                ],
              ),
            ),
            
            // Privacy and Terms
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      _showPrivacyDialog(context);
                    },
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(color: Color(0xFF1E88E5)),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  TextButton(
                    onPressed: () {
                      _showTermsDialog(context);
                    },
                    child: Text(
                      'Terms of Service',
                      style: TextStyle(color: Color(0xFF1E88E5)),
                    ),
                  ),
                ],
              ),
            ),
            
            // Copyright
            SizedBox(height: 20),
            Text(
              '© 2024 INSURE App. All rights reserved.',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String? content, {Widget? child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E88E5),
            ),
          ),
          SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF1E88E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Color(0xFF1E88E5),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF1E88E5), size: 20),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String platform) {
    return InkWell(
      onTap: () {
        // Handle social media links
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF1E88E5).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Color(0xFF1E88E5)),
            SizedBox(height: 4),
            Text(
              platform,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF1E88E5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'At INSURE, we respect your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our app.\n\n'
            'Information We Collect:\n'
            '• Personal information you provide when registering\n'
            '• Product warranty information you add\n'
            '• Images you upload (warranty cards, receipts, products)\n\n'
            'How We Use Your Information:\n'
            '• To provide warranty management services\n'
            '• To send notifications about expiring warranties\n'
            '• To improve our app functionality\n\n'
            'Data Security:\n'
            'We use industry-standard security measures to protect your data. All information is encrypted and stored securely in the cloud.\n\n'
            'Your Rights:\n'
            'You can access, update, or delete your personal information at any time through the app settings.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text(
            'By using INSURE, you agree to these terms of service.\n\n'
            'Acceptance of Terms:\n'
            'By accessing and using this app, you accept and agree to be bound by the terms and provision of this agreement.\n\n'
            'Use License:\n'
            'Permission is granted to temporarily use INSURE for personal, non-commercial warranty management purposes.\n\n'
            'Disclaimer:\n'
            'The information in INSURE is provided on an "as is" basis. To the fullest extent permitted by law, INSURE excludes all representations, warranties, obligations, and liabilities arising out of or in connection with your use of this app.\n\n'
            'Limitations:\n'
            'INSURE will not be liable for any damages, including but not limited to, direct, indirect, special, incidental, or consequential damages or losses that may result from the use of or inability to use this app.\n\n'
            'Governing Law:\n'
            'These terms and conditions are governed by and construed in accordance with applicable laws.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
