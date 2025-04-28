import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';
import 'package:flutter/foundation.dart';

class AddUnit {
  final Dio dio;

  AddUnit(this.dio);

  Future<String> addunit({
    required String? token,
    required String? productID,
    required List<Map<String, dynamic>>? units,
  }) async {
    try {
      // Debug print the request data
      debugPrint('Adding unit with data:');
      debugPrint('ProductID: $productID');
      debugPrint('Units: $units');

      final processedUnits = units?.map((unit) {
        return {
          'sku': unit['sku']?.toString(),
          'properties': unit['properties'],
        };
      }).toList();

      // Debug print the processed data
      debugPrint('Processed units: $processedUnits');

      final response = await dio.patch(
        '$baseUrl/products/add-units',
        data: {
          "productID": productID,
          "units": processedUnits,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      // Debug print the response
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Unit added successfully";
      }

      return response.data['message'] ?? 'Failed to add unit';
    } on DioException catch (e) {
      debugPrint('DioError: ${e.message}');
      debugPrint('DioError response: ${e.response?.data}');

      if (e.response != null) {
        return e.response?.data['error'] ??
            'Failed to add unit: ${e.response?.statusCode}';
      }
      return 'Network error: ${e.message}';
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return 'Unexpected error: ${e.toString()}';
    }
  }

  // Helper method to ensure all properties have correct types
  static Map<String, dynamic> _processProperties(dynamic properties) {
    if (properties == null) return {};

    final Map<String, dynamic> result = {};

    if (properties is Map) {
      properties.forEach((key, value) {
        // Keep all values as strings to avoid type conversion issues
        result[key.toString()] = value.toString();
      });
    }

    return result;
  }
}
