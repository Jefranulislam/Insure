import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(color: Color.fromARGB(255, 68, 68, 68)),
        ),
        backgroundColor: Color(0xFFF0F4F6),
        iconTheme: IconThemeData(color: Color.fromARGB(255, 68, 68, 68)),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('warranties')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We\'ll notify you when warranties are expiring',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Filter products that are expiring soon (30 days or less)
          var expiringProducts = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var expiryDate = (data['expiryDate'] as Timestamp).toDate();
            var daysLeft = expiryDate.difference(DateTime.now()).inDays;
            return daysLeft <= 30; // 30 days or less
          }).toList();

          // Sort by days remaining (most urgent first)
          expiringProducts.sort((a, b) {
            var aData = a.data() as Map<String, dynamic>;
            var bData = b.data() as Map<String, dynamic>;
            var aExpiry = (aData['expiryDate'] as Timestamp).toDate();
            var bExpiry = (bData['expiryDate'] as Timestamp).toDate();
            var aDays = aExpiry.difference(DateTime.now()).inDays;
            var bDays = bExpiry.difference(DateTime.now()).inDays;
            return aDays.compareTo(
              bDays,
            ); // Ascending order (most urgent first)
          });

          if (expiringProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.green[400]),
                  SizedBox(height: 16),
                  Text(
                    'All warranties are up to date!',
                    style: TextStyle(fontSize: 18, color: Colors.green[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No warranties are expiring soon',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Notification Summary
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[600], size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Warranty Alert',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.orange[800],
                            ),
                          ),
                          Text(
                            '${expiringProducts.length} ${expiringProducts.length == 1 ? 'product' : 'products'} expiring soon',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Expiring Products List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: expiringProducts.length,
                  itemBuilder: (context, index) {
                    var data =
                        expiringProducts[index].data() as Map<String, dynamic>;
                    return NotificationCard(
                      warrantyId: expiringProducts[index].id,
                      productName: data['productName'] ?? '',
                      brand: data['brand'] ?? '',
                      category: data['category'] ?? '',
                      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
                      purchaseDate: (data['purchaseDate'] as Timestamp)
                          .toDate(),
                      imageUrl: data['imageUrl'],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String warrantyId;
  final String productName;
  final String brand;
  final String category;
  final DateTime expiryDate;
  final DateTime purchaseDate;
  final String? imageUrl;

  NotificationCard({
    required this.warrantyId,
    required this.productName,
    required this.brand,
    required this.category,
    required this.expiryDate,
    required this.purchaseDate,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    final isExpired = daysLeft < 0;
    final isExpiringSoon = daysLeft <= 7; // Very urgent (1 week or less)
    final isExpiringSoonish =
        daysLeft <= 30; // Somewhat urgent (1 month or less)

    Color priorityColor;
    IconData priorityIcon;
    String priorityText;

    if (isExpired) {
      priorityColor = Colors.red;
      priorityIcon = Icons.error;
      priorityText = 'EXPIRED';
    } else if (isExpiringSoon) {
      priorityColor = Colors.red;
      priorityIcon = Icons.warning;
      priorityText = 'URGENT';
    } else if (isExpiringSoonish) {
      priorityColor = Colors.orange;
      priorityIcon = Icons.schedule;
      priorityText = 'EXPIRING SOON';
    } else {
      priorityColor = Colors.green;
      priorityIcon = Icons.check_circle;
      priorityText = 'GOOD';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: priorityColor.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/product-details',
            arguments: warrantyId,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.inventory,
                              color: Colors.grey[400],
                              size: 30,
                            );
                          },
                        ),
                      )
                    : Icon(Icons.inventory, color: Colors.grey[400], size: 30),
              ),
              SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            productName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: priorityColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            priorityText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: priorityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          brand,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(priorityIcon, color: priorityColor, size: 16),
                        SizedBox(width: 4),
                        Text(
                          isExpired
                              ? 'Expired ${(-daysLeft)} days ago'
                              : '$daysLeft days remaining',
                          style: TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Expires: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Action Icon
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
