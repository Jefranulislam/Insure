import 'dart:convert';
import 'dart:typed_data';

class ImgurService {
  /// Upload image using base64 data URLs - works perfectly in browsers
  static Future<String?> uploadImage(
    Uint8List imageBytes,
    String filename,
  ) async {
    try {
      print('🔄 Processing image: $filename');
      print('📊 Image size: ${imageBytes.length} bytes');

      // For web, use data URLs which work perfectly without external APIs
      // Limit to 500KB to prevent browser crashes and Firestore document size issues
      if (imageBytes.length > 500 * 1024) {
        // 500KB limit for stability
        print('❌ Image too large for data URL (max 500KB)');
        return null;
      }

      // Create base64 data URL
      final base64Image = base64Encode(imageBytes);
      final mimeType = _getMimeType(filename);
      final dataUrl = 'data:$mimeType;base64,$base64Image';

      print('✅ Image converted to data URL successfully!');
      print('� Data URL length: ${dataUrl.length} characters');

      return dataUrl;
    } catch (e) {
      print('❌ Error processing image: $e');
      return null;
    }
  }

  /// Get MIME type based on file extension
  static String _getMimeType(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Upload multiple images and return URLs
  static Future<List<String?>> uploadMultipleImages(
    List<Uint8List> imageBytesList,
    List<String> filenames,
  ) async {
    final List<String?> urls = [];

    for (int i = 0; i < imageBytesList.length; i++) {
      final url = await uploadImage(imageBytesList[i], filenames[i]);
      urls.add(url);
    }

    return urls;
  }

  /// Check if URL is a valid image URL
  static bool isValidImageUrl(String url) {
    return url.startsWith('data:image/') ||
        url.startsWith('https://') &&
            (url.contains('.jpg') ||
                url.contains('.jpeg') ||
                url.contains('.png') ||
                url.contains('.gif'));
  }

  /// Compress image if too large (basic compression)
  static Uint8List? compressImage(Uint8List imageBytes) {
    // For now, just return original bytes
    // In a real app, you'd use image compression library
    return imageBytes.length > 2 * 1024 * 1024 ? null : imageBytes;
  }
}
