import 'package:dio/dio.dart';
import '../consts/consts.dart';

class AdminAnalyticsService {
  final Dio _dio;

  AdminAnalyticsService(this._dio);

  Future<Map<String, dynamic>> getAnalytics({
    String? productId,
    String? interval,
    DateTime? startDate,
    DateTime? endDate,
    String? token,
  }) async {
    try {
      // Only include non-null and non-'all' parameters
      Map<String, dynamic> queryParams = {};
      
      if (interval != null && interval.isNotEmpty) {
        queryParams['interval'] = interval;
      }
      
      if (productId != null && productId != 'all') {
        queryParams['product_id'] = productId;
      }
      
      // Only add date parameters if both dates are selected
      if (startDate != null && endDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _dio.get(
        '$baseUrl/analytics/admin-analytics',
        queryParameters: queryParams,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      }
      
      throw Exception('Failed to fetch analytics data');
    } catch (e) {
      print('Error fetching analytics: $e');
      throw Exception('Failed to fetch analytics data: $e');
    }
  }
} 