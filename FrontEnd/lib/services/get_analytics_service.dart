import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/analytics_model.dart';

class GetAnalyticsService {
  final Dio _dio;

  GetAnalyticsService(this._dio);

  Future<AnalyticsModel> getAnalytics(String token, String productId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/analytics/current-month-overview-analytics',
        queryParameters: {'product_id': productId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return AnalyticsModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load analytics data');
      }
    } catch (e) {
      throw Exception('Error fetching analytics: ${e.toString()}');
    }
  }
}
