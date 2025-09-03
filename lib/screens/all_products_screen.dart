import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('All Products', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E88E5),
        iconTheme: IconThemeData(color: Colors.white),
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
                          selectedColor: Color(0xFF1E88E5).withOpacity(0.2),
                          checkmarkColor: Color(0xFF1E88E5),
                          labelStyle: TextStyle(
                            color: isSelected ? Color(0xFF1E88E5) : Colors.black,
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
                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .orderBy('createdAt', descending: true)
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
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var warranties = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  
                  // Filter by search query
                  if (_searchQuery.isNotEmpty) {
                    final productName = data['productName'].toString().toLowerCase();
                    final brand = data['brand'].toString().toLowerCase();
                    if (!productName.contains(_searchQuery) && !brand.contains(_searchQuery)) {
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
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
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
                    return ProductCard(
                      warrantyId: warranties[index].id,
                      productName: data['productName'] ?? '',
                      brand: data['brand'] ?? '',
                      category: data['category'] ?? '',
                      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
                      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
                      price: data['price']?.toDouble() ?? 0.0,
                      imageUrl: data['imageUrl'],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                    : Icon(
                        Icons.inventory,
                        color: Colors.grey[400],
                        size: 30,
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
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
