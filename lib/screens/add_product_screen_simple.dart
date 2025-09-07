import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/manufacturer_email_service.dart';

class AddProductScreenSimple extends StatefulWidget {
  @override
  _AddProductScreenSimpleState createState() => _AddProductScreenSimpleState();
}

class _AddProductScreenSimpleState extends State<AddProductScreenSimple> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _brandController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _purchaseDate;
  int _warrantyMonths = 12;
  String _selectedCategory = 'Electronics';
  bool _isLoading = false;

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

  Future<void> _saveWarranty() async {
    if (!_formKey.currentState!.validate() || _purchaseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Starting simple warranty save...');

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
          duration: Duration(seconds: 10),
        ),
      );

      // Get manufacturer email
      final manufacturerEmail = ManufacturerEmailService.getManufacturerEmail(
        _brandController.text.trim(),
      );

      // Calculate expiry date
      final expiryDate = _purchaseDate!.add(
        Duration(days: _warrantyMonths * 30),
      );

      // Prepare warranty data (NO IMAGES)
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
        'warrantyCardUrl': null, // No images for now
        'receiptUrl': null, // No images for now
        'imageUrl': null, // No images for now
        'createdAt': Timestamp.now(),
        'isActive': true,
      };

      print('Saving warranty data to Firestore...');

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('warranties')
          .add(warrantyData)
          .timeout(Duration(seconds: 10));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Warranty'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
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
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Brand
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter brand';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Serial Number
            TextFormField(
              controller: _serialNumberController,
              decoration: InputDecoration(
                labelText: 'Serial Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            // Category
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
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),

            // Purchase Date
            ListTile(
              title: Text(
                _purchaseDate == null
                    ? 'Select Purchase Date'
                    : 'Purchase Date: ${_purchaseDate!.toLocal().toString().split(' ')[0]}',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _purchaseDate = date;
                  });
                }
              },
            ),
            SizedBox(height: 16),

            // Warranty Period
            Row(
              children: [
                Text('Warranty Period: '),
                Expanded(
                  child: Slider(
                    value: _warrantyMonths.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '$_warrantyMonths months',
                    onChanged: (value) {
                      setState(() {
                        _warrantyMonths = value.round();
                      });
                    },
                  ),
                ),
                Text('$_warrantyMonths months'),
              ],
            ),
            SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveWarranty,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Save Warranty', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
