import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/cloudinary_config.dart';

class ImageUploadException implements Exception {
  final String message;
  ImageUploadException(this.message);

  @override
  String toString() => message;
}

class ImageUploadService {
  /// Uploads the image to Cloudinary and returns its secure URL.
  Future<String> upload(XFile file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    try {
      final bytes = await file.readAsBytes();
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: file.name),
        );

      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode != 200) {
        throw ImageUploadException('Photo upload failed. Please try again.');
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      final url = data['secure_url'] as String?;
      if (url == null || url.isEmpty) {
        throw ImageUploadException('Photo upload failed. Please try again.');
      }
      return url;
    } on ImageUploadException {
      rethrow;
    } catch (_) {
      throw ImageUploadException(
        'Could not upload the photo. Check your connection and try again.',
      );
    }
  }
}