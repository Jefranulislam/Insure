import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/manufacturer_email_service.dart';
import '../services/imgur_service.dart';

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
  XFile? _warrantyCardImage;
  XFile? _receiptImage;
  XFile? _productImage;
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
                        _warrantyCardImage = image;
                        break;
                      case 'receipt':
                        _receiptImage = image;
                        break;
                      case 'product':
                        _productImage = image;
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
                        _warrantyCardImage = image;
                        break;
                      case 'receipt':
                        _receiptImage = image;
                        break;
                      case 'product':
                        _productImage = image;
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

  Future<String?> _uploadImage(XFile? imageFile, String folder) async {
    if (imageFile == null) return null;

    try {
      print('🚀 Starting Imgur upload for $folder...');

      // Read bytes with size limit
      final bytes = await imageFile.readAsBytes();
      print('📊 Image size: ${bytes.length} bytes for file: ${imageFile.name}');

      // Check size limit (data URLs work best with smaller images)
      if (bytes.length > 2 * 1024 * 1024) {
        // 2MB limit for data URLs
        print('❌ Image too large for data URL storage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image too large (max 2MB). Please use a smaller image or compress it.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return null;
      }

      // Generate filename
      final fileName = '${folder}_${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      
      print('📤 Processing image with data URL...');
      
      // Upload using data URL (instant, no network required)
      final imageUrl = await ImgurService.uploadImage(bytes, fileName);
      
      if (imageUrl != null) {
        print('✅ Image processed successfully!');
        print('� Data URL length: ${imageUrl.length} characters');
        return imageUrl;
      } else {
        print('❌ Image processing failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image processing failed. Please try a smaller image.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return null;
      }
    } catch (e) {
      print('❌ Error uploading image to Imgur: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload error: ${e.toString().length > 100 ? e.toString().substring(0, 100) + '...' : e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
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
      print('Starting warranty save process...');

      // Show progress message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Saving warranty...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      String? warrantyCardUrl;
      String? receiptUrl;
      String? productImageUrl;

      // Try to upload images, but don't fail if uploads fail
      if (_warrantyCardImage != null) {
        print('📄 Uploading warranty card...');
        warrantyCardUrl = await _uploadImage(
          _warrantyCardImage!,
          'warranty_cards',
        );
        print('✅ Warranty card result: $warrantyCardUrl');
      }

      if (_receiptImage != null) {
        print('🧾 Uploading receipt...');
        receiptUrl = await _uploadImage(_receiptImage!, 'receipts');
        print('✅ Receipt result: $receiptUrl');
      }

      if (_productImage != null) {
        print('📸 Uploading product image...');
        productImageUrl = await _uploadImage(_productImage!, 'product_images');
        print('✅ Product image result: $productImageUrl');
      }

      print('🔄 All uploads completed! Saving to Firestore...');
      
      // Check upload success rate
      final totalImages = (_warrantyCardImage != null ? 1 : 0) + 
                         (_receiptImage != null ? 1 : 0) + 
                         (_productImage != null ? 1 : 0);
      final successfulUploads = (warrantyCardUrl != null ? 1 : 0) + 
                               (receiptUrl != null ? 1 : 0) + 
                               (productImageUrl != null ? 1 : 0);
      
      print('📊 Upload summary: $successfulUploads/$totalImages images uploaded successfully');
      
      if (totalImages > 0 && successfulUploads == 0) {
        // All uploads failed - show option to save without images
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All image uploads failed. Saving product without images.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (totalImages > 0 && successfulUploads < totalImages) {
        // Some uploads failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Some images failed to upload. Saved $successfulUploads/$totalImages images.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Get manufacturer email
      final manufacturerEmail = ManufacturerEmailService.getManufacturerEmail(
        _brandController.text.trim(),
      );

      // Calculate expiry date
      final expiryDate = _purchaseDate!.add(
        Duration(days: _warrantyMonths * 30),
      );

      // Prepare warranty data
      final warrantyData = {
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'productName': _productNameController.text.trim(),
        'brand': _brandController.text.trim(),
        'manufacturerEmail': manufacturerEmail,
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
      };

      print('💾 Saving warranty data:');
      print('- Product: ${warrantyData['productName']}');
      print('- Brand: ${warrantyData['brand']}');
      print('- Warranty Card URL: ${warrantyData['warrantyCardUrl']}');
      print('- Receipt URL: ${warrantyData['receiptUrl']}');
      print('- Product Image URL: ${warrantyData['imageUrl']}');

      // Save to Firestore with timeout
      await FirebaseFirestore.instance
          .collection('warranties')
          .add(warrantyData)
          .timeout(Duration(seconds: 15));

      print('Warranty saved successfully!');

      // Hide the progress snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Warranty saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error saving warranty: $e');

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving warranty: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveWarrantySimple() async {
    if (!_formKey.currentState!.validate() || _purchaseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Starting simple warranty save (no images)...');

      // Show progress message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Saving warranty (no images)...'),
            ],
          ),
          duration: Duration(seconds: 15),
        ),
      );

      // Calculate expiry date
      final expiryDate = _purchaseDate!.add(
        Duration(days: _warrantyMonths * 30),
      );

      // Get manufacturer email
      final manufacturerEmail = ManufacturerEmailService.getManufacturerEmail(
        _brandController.text.trim(),
      );

      // Save to Firestore directly without images
      await FirebaseFirestore.instance
          .collection('warranties')
          .add({
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'productName': _productNameController.text.trim(),
            'brand': _brandController.text.trim(),
            'manufacturerEmail': manufacturerEmail,
            'serialNumber': _serialNumberController.text.trim(),
            'price': double.tryParse(_priceController.text) ?? 0.0,
            'category': _selectedCategory,
            'purchaseDate': Timestamp.fromDate(_purchaseDate!),
            'warrantyMonths': _warrantyMonths,
            'expiryDate': Timestamp.fromDate(expiryDate),
            'notes': _notesController.text.trim(),
            'warrantyCardUrl': null,
            'receiptUrl': null,
            'imageUrl': null,
            'createdAt': Timestamp.now(),
            'isActive': true,
          })
          .timeout(Duration(seconds: 10));

      print('Simple warranty saved successfully!');

      // Hide the progress snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Warranty saved successfully (no images)!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error saving simple warranty: $e');

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving warranty: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
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

            // Brand Autocomplete
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.length < 2) {
                  return const Iterable<String>.empty();
                }
                final suggestions =
                    ManufacturerEmailService.searchManufacturers(
                      textEditingValue.text,
                    );
                return suggestions.take(
                  5,
                ); // Limit to 5 suggestions for performance
              },
              onSelected: (String selection) {
                _brandController.text = selection;
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      decoration: InputDecoration(
                        labelText: 'Brand *',
                        border: OutlineInputBorder(),
                        hintText: 'Type manufacturer name...',
                        suffixIcon: Icon(Icons.search),
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Brand is required' : null,
                      onChanged: (value) => _brandController.text = value,
                    );
                  },
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
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Saving...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Save Warranty',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),

            SizedBox(height: 12),

            // Secondary save button without images
            OutlinedButton(
              onPressed: _isLoading ? null : () => _saveWarrantySimple(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color.fromARGB(255, 68, 68, 68)),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save_outlined,
                    color: Color.fromARGB(255, 68, 68, 68),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Save Without Images (Faster)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 68, 68, 68),
                    ),
                  ),
                ],
              ),
            ),

            // Help text
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Images now save instantly using optimized data storage! Works perfectly on web and mobile. Keep images under 2MB for best performance.',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerCard(String title, XFile? image, VoidCallback onTap) {
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
                child: image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 30,
                        ),
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
                      image != null
                          ? '✓ Image selected - Tap to change'
                          : 'Tap to add photo',
                      style: TextStyle(
                        color: image != null
                            ? Colors.green[600]
                            : Colors.grey[600],
                        fontSize: 14,
                      ),
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
