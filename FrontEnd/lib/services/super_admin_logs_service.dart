import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';

class SuperAdminLogsService {
  final Dio dio = Dio();

  Future<Map<String, dynamic>> getSuperAdminLogs(String? token, {
    String? adminName, 
    String? startDate, 
    String? endDate,
    String? action
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (adminName != null) queryParams['adminName'] = adminName;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (action != null && action.isNotEmpty) queryParams['action'] = action;

      Response response = await dio.get(
        '$baseUrl/analytics/super-admin-logs',
        queryParameters: queryParams,
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        })
      );
      
      return response.data;
    } catch (e) {
      print('SuperAdminLogsService Error: $e');
      throw Exception('Error: $e');
    }
  }
} 