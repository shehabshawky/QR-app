import 'package:dio/dio.dart';
import 'package:login_page/models/client_product_list_model.dart';
import 'package:login_page/models/utils.dart';
import 'api_client.dart';
import 'base_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ClientService extends BaseService {
  final ApiClient _apiClient = ApiClient();

  Future<Response> validateQRCode({
    required String? productID,
    required String? sku,
    String? token,
  }) async {
    try {
      _apiClient.setAuthToken(token);

      // Send productID and sku data instead of an image file
      return await _apiClient.dio.patch(
        '/products/scan/', // Your endpoint
        data: {
          'productID': productID,
          'sku': sku,
        },
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }

  Future<List<ProductModel>> getClientProducts({
    String? token,
    String? searchTerm,
  }) async {
    try {
      _apiClient.setAuthToken(token);
      String endpoint = '/products/scanned-products';

      // Add search parameter to the URL if provided
      if (searchTerm != null && searchTerm.isNotEmpty) {
        endpoint += '?name=$searchTerm';
      }

      final response = await _apiClient.dio.get(endpoint);

      if (response.statusCode == 200) {
        print("API Response: ${response.data}");
        final List<dynamic> data = response.data;
        final products =
            data.map((item) => ProductModel.fromJson(item)).toList();
        print("Parsed Products: ${products.map((p) => p.name).join(', ')}");
        return products;
      } else {
        throw Exception(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("DioException in getClientProducts: ${e.message}");
      throw Exception(handleDioError(e));
    } catch (e) {
      print("Unexpected error in getClientProducts: $e");
      rethrow;
    }
  }

  // Method to support both web-compatible and legacy file uploads
  Future<Response> createReport({
    required String productID,
    required String sku,
    ImageData? imageData,
    File? image,
    String? token,
  }) async {
    try {
      _apiClient.setAuthToken(token);

      // For backward compatibility
      if (imageData == null && image == null) {
        throw ArgumentError("Either imageData or image must be provided");
      }

      // Use the uploadFile method from ApiClient which handles multipart/form-data
      return await _apiClient.uploadFile(
        '/reports',
        imageData ?? image!, // Use imageData if available, otherwise use image
        'image',
        extraData: {
          'productID': productID,
          'sku': sku,
        },
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
