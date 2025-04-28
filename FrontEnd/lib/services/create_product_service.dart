// Add this import
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:login_page/consts/consts.dart';

class CreateProductService {
  final Dio dio;
  CreateProductService(this.dio);

  Future<String> setProduct({
    String? name,
    String? price,
    String? warranty_duration,
    String? description,
    String? category,
    String? release_date,
    dynamic image, // Can be either File or Uint8List
    String? properties,
    required String? token,
  }) async {
    try {
      MultipartFile? imageFile;

      if (image != null) {
        if (kIsWeb) {
          imageFile = MultipartFile.fromBytes(
            image as Uint8List,
            filename: 'product_image.jpg',
          );
        } else {
          imageFile = await MultipartFile.fromFile(
            (image as File).path,
            filename: 'product_image.jpg',
          );
        }
      }

      final formData = FormData.fromMap({
        'name': name,
        'price': price,
        'warranty_duration': warranty_duration,
        'description': description,
        'category': category,
        'release_date': release_date,
        'properties': properties,
        if (imageFile != null) 'image': imageFile,
      });

      Response response = await dio.post(
        '$baseUrl/products/add-product',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data.toString() ?? 'Unknown error';
      } else {
        return "Network error: ${e.message}";
      }
    }
  }
}
