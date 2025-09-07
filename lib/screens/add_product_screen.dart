import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import '../services/manufacturer_email_service.dart';
import '../services/cloudinary_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _storeController = TextEditingController();
  final _notesController = TextEditingController();

  XFile? _productImage;
  XFile? _receiptImage;
  XFile? _warrantyCardImage;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Warranty period in months (1 month to 120 months = 10 years)
  double _warrantyMonths = 12.0;

  // Brand selection variables
  String? _selectedBrand;
  List<String> _filteredBrands = [];
  bool _showBrandDropdown = false;

  @override
  void initState() {
    super.initState();
    _filteredBrands = ManufacturerEmailService.getAllManufacturers();
  }

  // Helper function to format warranty period
  String _formatWarrantyPeriod(double months) {
    int monthsInt = months.round();
    if (monthsInt < 12) {
      return '$monthsInt ${monthsInt == 1 ? 'month' : 'months'}';
    } else {
      int years = monthsInt ~/ 12;
      int remainingMonths = monthsInt % 12;
      if (remainingMonths == 0) {
        return '$years ${years == 1 ? 'year' : 'years'}';
      } else {
        return '$years ${years == 1 ? 'year' : 'years'} $remainingMonths ${remainingMonths == 1 ? 'month' : 'months'}';
      }
    }
  }

  // Filter brands based on search text
  void _filterBrands(String query) {
    setState(() {
      _filteredBrands = ManufacturerEmailService.searchManufacturers(query);
      _showBrandDropdown = query.isNotEmpty;
    });
  }

  // Select a brand from dropdown
  void _selectBrand(String brand) {
    setState(() {
      _selectedBrand = brand;
      _brandController.text = brand;
      _showBrandDropdown = false;
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _purchaseDateController.dispose();
    _purchasePriceController.dispose();
    _storeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          switch (type) {
            case 'product':
              _productImage = pickedFile;
              break;
            case 'receipt':
              _receiptImage = pickedFile;
              break;
            case 'warranty':
              _warrantyCardImage = pickedFile;
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _purchaseDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(
    XFile imageFile,
    String folder,
  ) async {
    try {
      print('Uploading image to Cloudinary...');
      final imageUrl = await CloudinaryService.uploadImage(imageFile, folder);
      print('Image uploaded to Cloudinary: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      throw e;
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation
    if (_brandController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a brand'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_purchaseDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a purchase date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload images to Firebase Storage
      String? productImageUrl;
      String? receiptImageUrl;
      String? warrantyCardImageUrl;

      // Upload product image
      if (_productImage != null) {
        print('Uploading product image...');
        productImageUrl = await _uploadImageToCloudinary(
          _productImage!,
          'insure/product_images',
        );
        print('Product image uploaded: $productImageUrl');
      }

      // Upload receipt image
      if (_receiptImage != null) {
        print('Uploading receipt image...');
        receiptImageUrl = await _uploadImageToCloudinary(
          _receiptImage!,
          'insure/receipt_images',
        );
        print('Receipt image uploaded: $receiptImageUrl');
      }

      // Upload warranty card image
      if (_warrantyCardImage != null) {
        print('Uploading warranty card image...');
        warrantyCardImageUrl = await _uploadImageToCloudinary(
          _warrantyCardImage!,
          'insure/warranty_card_images',
        );
        print('Warranty card image uploaded: $warrantyCardImageUrl');
      }

      // Create warranty data
      final warrantyData = <String, dynamic>{
        'productName': _productNameController.text.trim(),
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'serialNumber': _serialNumberController.text.trim(),
        'purchaseDate': _purchaseDateController.text.trim(),
        'warrantyPeriod': _formatWarrantyPeriod(_warrantyMonths),
        'purchasePrice': _purchasePriceController.text.trim(),
        'store': _storeController.text.trim(),
        'notes': _notesController.text.trim(),
        'userId': user.uid,
        'createdAt':
            Timestamp.now(), // Use Timestamp.now() instead of FieldValue.serverTimestamp()
      };

      // Only add image URLs if they exist
      if (productImageUrl != null && productImageUrl.isNotEmpty) {
        warrantyData['productImageUrl'] = productImageUrl;
      }
      if (receiptImageUrl != null && receiptImageUrl.isNotEmpty) {
        warrantyData['receiptImageUrl'] = receiptImageUrl;
      }
      if (warrantyCardImageUrl != null && warrantyCardImageUrl.isNotEmpty) {
        warrantyData['warrantyCardImageUrl'] = warrantyCardImageUrl;
      }

      print('Warranty data to save:');
      warrantyData.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('warranties')
          .add(warrantyData);

      print('Warranty saved successfully to Firestore');

      // Send notification email to manufacturer if brand is selected
      if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        try {
          final manufacturerEmail =
              ManufacturerEmailService.getManufacturerEmail(_selectedBrand!);
          if (manufacturerEmail != null) {
            print(
              'Manufacturer email found: $manufacturerEmail for $_selectedBrand',
            );
            // Here you would integrate with your email service
            // For now, just log that email would be sent
            print('Would send warranty notification to: $manufacturerEmail');
          }
        } catch (emailError) {
          print('Failed to send manufacturer email: $emailError');
          // Don't show error to user as the main operation succeeded
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Warranty saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving warranty: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImagePicker(String label, XFile? image, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery, type),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                            image.path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text('Error loading image'),
                              );
                            },
                          )
                        : Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text('Error loading image'),
                              );
                            },
                          ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add $label',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera, type),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery, type),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Warranty'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Information
                    const Text(
                      'Product Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _productNameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _brandController,
                                decoration: const InputDecoration(
                                  labelText: 'Brand *',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.search),
                                ),
                                onChanged: _filterBrands,
                                onTap: () {
                                  setState(() {
                                    _showBrandDropdown = true;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a brand';
                                  }
                                  return null;
                                },
                              ),
                              if (_showBrandDropdown &&
                                  _filteredBrands.isNotEmpty)
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _filteredBrands.length > 10
                                        ? 10
                                        : _filteredBrands.length,
                                    itemBuilder: (context, index) {
                                      final brand = _filteredBrands[index];
                                      return ListTile(
                                        title: Text(brand),
                                        dense: true,
                                        onTap: () => _selectBrand(brand),
                                        trailing: Icon(
                                          Icons.email,
                                          size: 16,
                                          color:
                                              ManufacturerEmailService.getManufacturerEmail(
                                                    brand,
                                                  ) !=
                                                  null
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _modelController,
                            decoration: const InputDecoration(
                              labelText: 'Model',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _serialNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Serial Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Purchase Information
                    const Text(
                      'Purchase Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _purchaseDateController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Date *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: _selectDate,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select the purchase date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Warranty Period Slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Warranty Period: ${_formatWarrantyPeriod(_warrantyMonths)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Theme.of(context).primaryColor,
                            inactiveTrackColor: Colors.grey[300],
                            thumbColor: Theme.of(context).primaryColor,
                            overlayColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.2),
                            valueIndicatorColor: Theme.of(context).primaryColor,
                            showValueIndicator: ShowValueIndicator.always,
                          ),
                          child: Slider(
                            value: _warrantyMonths,
                            min: 1.0,
                            max: 120.0, // 10 years in months
                            divisions: 119, // 1 month to 120 months
                            label: _formatWarrantyPeriod(_warrantyMonths),
                            onChanged: (value) {
                              setState(() {
                                _warrantyMonths = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _purchasePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _storeController,
                      decoration: const InputDecoration(
                        labelText: 'Store/Retailer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Images
                    const Text(
                      'Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildImagePicker(
                      'Product Photo',
                      _productImage,
                      'product',
                    ),
                    const SizedBox(height: 24),

                    _buildImagePicker(
                      'Receipt Photo',
                      _receiptImage,
                      'receipt',
                    ),
                    const SizedBox(height: 24),

                    _buildImagePicker(
                      'Warranty Card Photo',
                      _warrantyCardImage,
                      'warranty',
                    ),
                    const SizedBox(height: 24),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Save Warranty',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
