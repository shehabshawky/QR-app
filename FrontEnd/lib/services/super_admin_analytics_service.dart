import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';

class SuperAdminAnalyticsService {
  final Dio dio = Dio();

  Future<Map<String, dynamic>> getSuperAdminAnalytics(String? token) async {
    try {
      Response response = await dio.get(
        '$baseUrl/analytics/super-admin-analytics',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        })
      );
      
      return response.data;
    } catch (e) {
      print('SuperAdminAnalyticsService Error: $e');
      throw Exception('Error: $e');
    }
  }
} 