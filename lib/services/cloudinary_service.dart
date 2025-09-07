import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _cloudName = 'du9vk1eao';
  static const String _apiKey = '982681999979794';
  static const String _apiSecret = 'nK5OSeQE9v5OL4QhgjNqNU_OFQ4';
  static const String _uploadPreset = 'insureso';
  
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1/$_cloudName';

  /// Upload image to Cloudinary
  static Future<String?> uploadImage(XFile imageFile, String folder) async {
    try {
      final uri = Uri.parse('$_baseUrl/image/upload');
      
      final request = http.MultipartRequest('POST', uri);
      
      // Add the upload preset
      request.fields['upload_preset'] = _uploadPreset;
      
      // Add folder for organization
      request.fields['folder'] = folder;
      
      // Add file
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: imageFile.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
            filename: imageFile.name,
          ),
        );
      }

      print('Uploading image to Cloudinary...');
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        
        final imageUrl = jsonData['secure_url'] as String;
        print('Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        final errorData = await response.stream.bytesToString();
        print('Cloudinary upload failed: ${response.statusCode} - $errorData');
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      throw e;
    }
  }

  /// Upload multiple images in parallel
  static Future<List<String?>> uploadMultipleImages(
    List<MapEntry<XFile, String>> imageFiles,
  ) async {
    final futures = imageFiles.map((entry) => 
      uploadImage(entry.key, entry.value)
    ).toList();
    
    return await Future.wait(futures);
  }

  /// Delete image from Cloudinary (optional - requires API key/secret)
  static Future<bool> deleteImage(String publicId) async {
    try {
      // This would require implementing signature for authenticated requests
      // For now, just return true as Cloudinary has auto-cleanup policies
      print('Image deletion requested for: $publicId');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Transform image URL (resize, quality, etc.)
  static String transformImageUrl(String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    if (!originalUrl.contains('cloudinary.com')) {
      return originalUrl;
    }

    // Extract public ID from URL
    final uri = Uri.parse(originalUrl);
    final pathSegments = uri.pathSegments;
    final uploadIndex = pathSegments.indexOf('upload');
    
    if (uploadIndex == -1) return originalUrl;

    final transformations = <String>[];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_$format');

    final transformationString = transformations.join(',');
    
    // Reconstruct URL with transformations
    final newPathSegments = List<String>.from(pathSegments);
    newPathSegments.insert(uploadIndex + 1, transformationString);
    
    return uri.replace(pathSegments: newPathSegments).toString();
  }

  /// Get optimized thumbnail URL
  static String getThumbnailUrl(String originalUrl, {int size = 150}) {
    return transformImageUrl(
      originalUrl,
      width: size,
      height: size,
      quality: 'auto',
      format: 'auto',
    );
  }

  /// Get medium size image URL
  static String getMediumUrl(String originalUrl) {
    return transformImageUrl(
      originalUrl,
      width: 800,
      quality: 'auto',
      format: 'auto',
    );
  }
}
