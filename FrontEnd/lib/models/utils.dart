import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class ImageData {
  final File? file; // For mobile
  final Uint8List? bytes; // For web
  final String? path;

  ImageData({this.file, this.bytes, this.path});
}

// Original function for backward compatibility
Future<File?> pickImage() async {
  if (kIsWeb) {
    throw Exception(
        "Image.file is not supported on Flutter Web. Consider using either Image.asset or Image.network instead.");
  }

  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    return File(image.path);
  } else {
    return null;
  }
}

// New function that supports web
Future<ImageData?> pickImageWeb() async {
  final picker = ImagePicker();
  final XFile? pickedImage =
      await picker.pickImage(source: ImageSource.gallery);

  if (pickedImage != null) {
    if (kIsWeb) {
      // For web platform
      final bytes = await pickedImage.readAsBytes();
      return ImageData(bytes: bytes, path: pickedImage.path);
    } else {
      // For mobile platform
      return ImageData(file: File(pickedImage.path), path: pickedImage.path);
    }
  } else {
    return null;
  }
}

Future<void> requestPermissions() async {
  if (!kIsWeb) {
    if (await Permission.camera.request().isGranted &&
        await Permission.storage.request().isGranted) {
      // Permissions granted
    } else {
      // Permissions denied
    }
  }
}
