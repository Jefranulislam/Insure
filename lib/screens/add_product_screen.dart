import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _brandController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _purchaseDate;
  int _warrantyMonths = 12;
  String _selectedCategory = 'Electronics';
  File? _warrantyCardImage;
  File? _receiptImage;
  File? _productImage;
  String? _warrantyCardImagePath;
  String? _receiptImagePath;
  String? _productImagePath;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Electronics',
    'Appliances',
    'Furniture',
    'Automotive',
    'Clothing',
    'Sports & Outdoors',
    'Home & Garden',
    'Other',
  ];

  Future<void> _pickImage(String type) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  setState(() {
                    switch (type) {
                      case 'warranty':
                        _warrantyCardImage = kIsWeb ? null : File(image.path);
                        _warrantyCardImagePath = image.path;
                        break;
                      case 'receipt':
                        _receiptImage = kIsWeb ? null : File(image.path);
                        _receiptImagePath = image.path;
                        break;
                      case 'product':
                        _productImage = kIsWeb ? null : File(image.path);
                        _productImagePath = image.path;
                        break;
                    }
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(() {
                    switch (type) {
                      case 'warranty':
                        _warrantyCardImage = kIsWeb ? null : File(image.path);
                        _warrantyCardImagePath = image.path;
                        break;
                      case 'receipt':
                        _receiptImage = kIsWeb ? null : File(image.path);
                        _receiptImagePath = image.path;
                        break;
                      case 'product':
                        _productImage = kIsWeb ? null : File(image.path);
                        _productImagePath = image.path;
                        break;
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadImage(File image, String folder) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        '$folder/${DateTime.now().millisecondsSinceEpoch}',
      );

      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveWarranty() async {
    if (!_formKey.currentState!.validate() || _purchaseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload images
      String? warrantyCardUrl;
      String? receiptUrl;
      String? productImageUrl;

      if (_warrantyCardImage != null) {
        warrantyCardUrl = await _uploadImage(
          _warrantyCardImage!,
          'warranty_cards',
        );
      }
      if (_receiptImage != null) {
        receiptUrl = await _uploadImage(_receiptImage!, 'receipts');
      }
      if (_productImage != null) {
        productImageUrl = await _uploadImage(_productImage!, 'product_images');
      }

      // Calculate expiry date
      final expiryDate = _purchaseDate!.add(
        Duration(days: _warrantyMonths * 30),
      );

      // Save to Firestore
      await FirebaseFirestore.instance.collection('warranties').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'productName': _productNameController.text.trim(),
        'brand': _brandController.text.trim(),
        'serialNumber': _serialNumberController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'category': _selectedCategory,
        'purchaseDate': Timestamp.fromDate(_purchaseDate!),
        'warrantyMonths': _warrantyMonths,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'notes': _notesController.text.trim(),
        'warrantyCardUrl': warrantyCardUrl,
        'receiptUrl': receiptUrl,
        'imageUrl': productImageUrl,
        'createdAt': Timestamp.now(),
        'isActive': true,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Warranty saved successfully!')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving warranty: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Product',
          style: TextStyle(color: Color.fromARGB(255, 68, 68, 68)),
        ),
        backgroundColor: Color(0xFFF0F4F6),
        iconTheme: IconThemeData(color: Color.fromARGB(255, 68, 68, 68)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Product Name
            TextFormField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: 'Product Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Product name is required' : null,
            ),
            SizedBox(height: 16),

            // Brand
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: 'Brand *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Brand is required' : null,
            ),
            SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            SizedBox(height: 16),

            // Serial Number
            TextFormField(
              controller: _serialNumberController,
              decoration: InputDecoration(
                labelText: 'Serial Number / Model',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Purchase Price
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Purchase Price',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Purchase Date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _purchaseDate = date);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Purchase Date *',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _purchaseDate == null
                      ? 'Select date'
                      : '${_purchaseDate!.day}/${_purchaseDate!.month}/${_purchaseDate!.year}',
                ),
              ),
            ),
            SizedBox(height: 16),

            // Warranty Period
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warranty Period: $_warrantyMonths months',
                  style: TextStyle(fontSize: 16),
                ),
                Slider(
                  value: _warrantyMonths.toDouble(),
                  min: 1,
                  max: 60,
                  divisions: 59,
                  label: '$_warrantyMonths months',
                  onChanged: (value) {
                    setState(() => _warrantyMonths = value.round());
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // Images Section
            Text(
              'Photos (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Warranty Card Image
            _buildImagePickerCard(
              'Warranty Card',
              _warrantyCardImage,
              () => _pickImage('warranty'),
            ),

            // Receipt Image
            _buildImagePickerCard(
              'Receipt',
              _receiptImage,
              () => _pickImage('receipt'),
            ),

            // Product Image
            _buildImagePickerCard(
              'Product Photo',
              _productImage,
              () => _pickImage('product'),
            ),

            SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Any additional information...',
              ),
            ),
            SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveWarranty,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 68, 68, 68),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Save Warranty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerCard(String title, File? image, VoidCallback onTap) {
    String? imagePath;

    // Get the image path for web compatibility
    if (title.contains('Warranty')) {
      imagePath = _warrantyCardImagePath;
    } else if (title.contains('Receipt')) {
      imagePath = _receiptImagePath;
    } else if (title.contains('Product')) {
      imagePath = _productImagePath;
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 100,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: (image != null || imagePath != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb && imagePath != null
                            ? Image.network(imagePath!, fit: BoxFit.cover)
                            : image != null && !kIsWeb
                            ? Image.file(image, fit: BoxFit.cover)
                            : Container(),
                      )
                    : Icon(
                        Icons.add_a_photo,
                        color: Colors.grey[400],
                        size: 30,
                      ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      image != null ? 'Tap to change' : 'Tap to add photo',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _brandController.dispose();
    _serialNumberController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
