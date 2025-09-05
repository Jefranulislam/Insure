import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductDetailsScreen extends StatefulWidget {
  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? warrantyId;
  Map<String, dynamic>? warrantyData;
  bool isLoading = true;

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
      ).showSnackBar(SnackBar(content: Text('Error loading product details')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Product Details',
            style: TextStyle(color: Color.fromARGB(255, 68, 68, 68)),
          ),
          backgroundColor: Color(0xFFF0F4F6),
          iconTheme: IconThemeData(color: Color.fromARGB(255, 68, 68, 68)),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (warrantyData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Product Details',
            style: TextStyle(color: Color.fromARGB(255, 68, 68, 68)),
          ),
          backgroundColor: Color(0xFFF0F4F6),
          iconTheme: IconThemeData(color: Color.fromARGB(255, 68, 68, 68)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Product not found',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final productName = warrantyData!['productName'] ?? '';
    final brand = warrantyData!['brand'] ?? '';
    final category = warrantyData!['category'] ?? '';
    final serialNumber = warrantyData!['serialNumber'] ?? '';
    final price = warrantyData!['price']?.toDouble() ?? 0.0;
    final notes = warrantyData!['notes'] ?? '';
    final purchaseDate = (warrantyData!['purchaseDate'] as Timestamp).toDate();
    final expiryDate = (warrantyData!['expiryDate'] as Timestamp).toDate();
    final warrantyMonths = warrantyData!['warrantyMonths'] ?? 0;
    final imageUrl = warrantyData!['imageUrl'];
    final warrantyCardUrl = warrantyData!['warrantyCardUrl'];
    final receiptUrl = warrantyData!['receiptUrl'];

    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysLeft <= 30;
    final isExpired = daysLeft < 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: TextStyle(color: Color.fromARGB(255, 68, 68, 68)),
        ),
        backgroundColor: Color(0xFFF0F4F6),
        iconTheme: IconThemeData(color: Color.fromARGB(255, 68, 68, 68)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Header
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.white,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Stack(
                      children: [
                        // Loading placeholder
                        Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 136, 136, 136),
                              ),
                            ),
                          ),
                        ),
                        // Actual image
                        Image.network(
                          imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
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
                            print('Error loading image: $error');
                            return _buildPlaceholderImage();
                          },
                        ),
                      ],
                    )
                  : _buildPlaceholderImage(),
            ),

            // Status Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: isExpired
                  ? Colors.red
                  : isExpiringSoon
                  ? Colors.orange
                  : Colors.green,
              child: Row(
                children: [
                  Icon(
                    isExpired
                        ? Icons.error
                        : isExpiringSoon
                        ? Icons.warning
                        : Icons.check_circle,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    isExpired
                        ? 'Warranty Expired ${(-daysLeft)} days ago'
                        : isExpiringSoon
                        ? 'Expiring Soon - $daysLeft days left'
                        : 'Active - $daysLeft days remaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Product Information
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
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
                    productName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    brand,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),

                  _buildInfoRow('Category', category),
                  if (serialNumber.isNotEmpty)
                    _buildInfoRow('Serial Number', serialNumber),
                  if (price > 0)
                    _buildInfoRow(
                      'Purchase Price',
                      '\$${price.toStringAsFixed(2)}',
                    ),
                  _buildInfoRow(
                    'Purchase Date',
                    DateFormat('MMM dd, yyyy').format(purchaseDate),
                  ),
                  _buildInfoRow('Warranty Period', '$warrantyMonths months'),
                  _buildInfoRow(
                    'Expiry Date',
                    DateFormat('MMM dd, yyyy').format(expiryDate),
                  ),

                  if (notes.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      notes,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),

            // Attachments Section
            if (warrantyCardUrl != null || receiptUrl != null)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(20),
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
                      'Attachments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    if (warrantyCardUrl != null)
                      _buildAttachmentTile(
                        'Warranty Card',
                        Icons.credit_card,
                        warrantyCardUrl,
                      ),

                    if (receiptUrl != null)
                      _buildAttachmentTile(
                        'Receipt',
                        Icons.receipt,
                        receiptUrl,
                      ),
                  ],
                ),
              ),

            SizedBox(height: 20),
          ],
        ),
      ),

      // Claim Warranty Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/claim-warranty',
              arguments: warrantyId,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1E88E5),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Claim Warranty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 60, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentTile(String title, IconData icon, String url) {
    return InkWell(
      onTap: () {
        _showImageDialog(url);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF1E88E5)),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.visibility, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text('View Image'),
                backgroundColor: Color(0xFF1E88E5),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      child: Center(child: Text('Failed to load image')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete this warranty? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              try {
                await FirebaseFirestore.instance
                    .collection('warranties')
                    .doc(warrantyId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product deleted successfully')),
                );

                Navigator.pop(context); // Go back to previous screen
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting product')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
