import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cloudinary_service.dart';

class AllProductsScreen extends StatefulWidget {
  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterCategory = 'All';

  final List<String> _categories = [
    'All',
    'Electronics',
    'Appliances',
    'Furniture',
    'Automotive',
    'Clothing',
    'Sports & Outdoors',
    'Home & Garden',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'All Products',
          style: TextStyle(color: Color.fromARGB(255, 68, 68, 68)),
        ),
        backgroundColor: Color(0xFFF0F4F6),
        iconTheme: IconThemeData(color: Color.fromARGB(255, 68, 68, 68)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey[100],
                    filled: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                SizedBox(height: 12),

                // Category Filter
                Container(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _filterCategory == category;

                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _filterCategory = category;
                            });
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: Color.fromARGB(
                            255,
                            136,
                            136,
                            136,
                          ).withOpacity(0.3),
                          checkmarkColor: Color.fromARGB(255, 68, 68, 68),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Color.fromARGB(255, 68, 68, 68)
                                : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Products List
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
                print('Stream state: ${snapshot.connectionState}');
                print('Has data: ${snapshot.hasData}');
                print('Docs count: ${snapshot.data?.docs.length ?? 0}');
                print(
                  'Current user: ${FirebaseAuth.instance.currentUser?.uid}',
                );

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Firestore error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 60, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error loading products',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(color: Colors.red[300]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add some products to get started',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/debug-products');
                          },
                          child: Text('Debug Info'),
                        ),
                      ],
                    ),
                  );
                }

                var warranties = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;

                  // Filter by search query
                  if (_searchQuery.isNotEmpty) {
                    final productName = data['productName']
                        .toString()
                        .toLowerCase();
                    final brand = data['brand'].toString().toLowerCase();
                    if (!productName.contains(_searchQuery) &&
                        !brand.contains(_searchQuery)) {
                      return false;
                    }
                  }

                  // Filter by category
                  if (_filterCategory != 'All') {
                    if (data['category'] != _filterCategory) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

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

                if (warranties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No products match your search',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: warranties.length,
                  itemBuilder: (context, index) {
                    var data = warranties[index].data() as Map<String, dynamic>;
                    // Safe timestamp handling
                    DateTime expiryDate;
                    DateTime purchaseDate;

                    try {
                      final expiryTimestamp = data['expiryDate'];
                      expiryDate = expiryTimestamp != null
                          ? (expiryTimestamp as Timestamp).toDate()
                          : DateTime.now().add(Duration(days: 365));
                    } catch (e) {
                      print('❌ Error parsing expiryDate: $e');
                      expiryDate = DateTime.now().add(Duration(days: 365));
                    }

                    try {
                      final purchaseTimestamp = data['purchaseDate'];
                      if (purchaseTimestamp != null) {
                        if (purchaseTimestamp is Timestamp) {
                          purchaseDate = purchaseTimestamp.toDate();
                        } else if (purchaseTimestamp is String) {
                          // Handle string dates like "7/8/2025"
                          try {
                            final parts = purchaseTimestamp.split('/');
                            if (parts.length == 3) {
                              purchaseDate = DateTime(
                                int.parse(parts[2]), // year
                                int.parse(parts[0]), // month
                                int.parse(parts[1]), // day
                              );
                            } else {
                              purchaseDate = DateTime.now();
                            }
                          } catch (e) {
                            print('❌ Error parsing string date: $e');
                            purchaseDate = DateTime.now();
                          }
                        } else {
                          purchaseDate = DateTime.now();
                        }
                      } else {
                        purchaseDate = DateTime.now();
                      }
                    } catch (e) {
                      print('❌ Error parsing purchaseDate: $e');
                      purchaseDate = DateTime.now();
                    }

                    return ProductCard(
                      warrantyId: warranties[index].id,
                      productName: data['productName'] ?? '',
                      brand: data['brand'] ?? '',
                      category: data['category'] ?? '',
                      expiryDate: expiryDate,
                      purchaseDate: purchaseDate,
                      price: data['price']?.toDouble() ?? 0.0,
                      imageUrl: data['productImageUrl'] ?? data['imageUrl'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String warrantyId;
  final String productName;
  final String brand;
  final String category;
  final DateTime expiryDate;
  final DateTime purchaseDate;
  final double price;
  final String? imageUrl;

  ProductCard({
    required this.warrantyId,
    required this.productName,
    required this.brand,
    required this.category,
    required this.expiryDate,
    required this.purchaseDate,
    required this.price,
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            // Loading placeholder
                            Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 136, 136, 136),
                                  ),
                                ),
                              ),
                            ),
                            // Actual image
                            Image.network(
                              CloudinaryService.getThumbnailUrl(
                                imageUrl!,
                                size: 160,
                              ),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[100],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color.fromARGB(
                                                  255,
                                                  136,
                                                  136,
                                                  136,
                                                ),
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.inventory,
                                    color: Colors.grey[400],
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.inventory,
                          color: Colors.grey[400],
                          size: 30,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    SizedBox(height: 4),
                    if (price > 0)
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Icon and Actions
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
