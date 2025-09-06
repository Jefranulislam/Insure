import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Color(0xFFF0F4F6), // Changed to light gray background
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/iconINSURESO.webp',
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.security,
                  color: Color.fromARGB(255, 68, 68, 68),
                  size: 30,
                );
              },
            ),
            // Removed INSURE text as requested
          ],
        ),
        actions: [
          // Notification Button with Dynamic Counter
          StreamBuilder<int>(
            stream: NotificationService.getExpiringProductsCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;

              return IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                icon: Stack(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: Color.fromARGB(255, 68, 68, 68),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          // Profile/Logout Button
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/welcome');
              } else if (value == 'debug') {
                Navigator.pushNamed(context, '/debug');
              } else if (value == 'debug-products') {
                Navigator.pushNamed(context, '/debug-products');
              } else if (value == 'claim-tracking') {
                Navigator.pushNamed(context, '/claim-tracking');
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'claim-tracking',
                child: Text('Track Claims'),
              ),
              PopupMenuItem(value: 'debug', child: Text('Debug Data')),
              PopupMenuItem(
                value: 'debug-products',
                child: Text('Debug Products'),
              ),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 68, 68, 68),
                          )
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search warranties...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Notification Banner (if there are expiring products)
          StreamBuilder<int>(
            stream: NotificationService.getExpiringProductsCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              if (count == 0) return SizedBox.shrink();

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.orange[600],
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Warranty Alert!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                              Text(
                                '$count ${count == 1 ? 'product' : 'products'} expiring soon',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.orange[600],
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Recent Warranties Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Warranties',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/all-products');
                  },
                  child: Text('View All'),
                ),
              ],
            ),
          ),

          // Warranties List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('warranties')
                  .where(
                    'userId',
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                  )
                  .snapshots(), // Removed orderBy to avoid index requirement
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No warranties added yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first warranty',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                var warranties = snapshot.data!.docs;

                // Sort manually by createdAt (newest first) since we can't use orderBy
                warranties.sort((a, b) {
                  var aData = a.data() as Map<String, dynamic>;
                  var bData = b.data() as Map<String, dynamic>;
                  var aCreated = aData['createdAt'] as Timestamp?;
                  var bCreated = bData['createdAt'] as Timestamp?;

                  if (aCreated == null && bCreated == null) return 0;
                  if (aCreated == null) return 1;
                  if (bCreated == null) return -1;

                  return bCreated.compareTo(
                    aCreated,
                  ); // Descending order (newest first)
                });

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  warranties = warranties.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return data['productName']
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery);
                  }).toList();
                }

                // Take only first 5 for home screen
                warranties = warranties.take(5).toList();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: warranties.length,
                  itemBuilder: (context, index) {
                    var data = warranties[index].data() as Map<String, dynamic>;
                    return WarrantyCard(
                      warrantyId: warranties[index].id,
                      productName: data['productName'] ?? '',
                      brand: data['brand'] ?? '',
                      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
                      imageUrl: data['imageUrl'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.pushNamed(context, '/all-products');
              break;
            case 2:
              Navigator.pushNamed(context, '/notifications');
              break;
            case 3:
              Navigator.pushNamed(context, '/about');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: StreamBuilder<int>(
              stream: NotificationService.getExpiringProductsCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Stack(
                  children: [
                    Icon(Icons.notifications),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-product');
        },
        backgroundColor: Color.fromARGB(
          255,
          68,
          68,
          68,
        ), // Changed from blue to gray
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class WarrantyCard extends StatelessWidget {
  final String warrantyId;
  final String productName;
  final String brand;
  final DateTime expiryDate;
  final String? imageUrl;

  WarrantyCard({
    required this.warrantyId,
    required this.productName,
    required this.brand,
    required this.expiryDate,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysLeft <= 30;
    final isExpired = daysLeft < 0;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 136, 136, 136),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Error loading image: $imageUrl');
                            print('Error details: $error');
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.red[300],
                                size: 25,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.inventory,
                          color: Colors.grey[400],
                          size: 25,
                        ),
                      ),
              ),
              SizedBox(width: 16),

              // Product Info
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
                    Text(
                      brand,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      isExpired
                          ? 'Expired ${(-daysLeft)} days ago'
                          : '$daysLeft days left',
                      style: TextStyle(
                        color: isExpired
                            ? Colors.red
                            : isExpiringSoon
                            ? Colors.orange
                            : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Icon
              Icon(
                isExpired
                    ? Icons.error
                    : isExpiringSoon
                    ? Icons.warning
                    : Icons.check_circle,
                color: isExpired
                    ? Colors.red
                    : isExpiringSoon
                    ? Colors.orange
                    : Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
