import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/report_model.dart';
import 'package:login_page/services/login_services.dart';

class GetReportsService {
  final Dio _dio = Dio();

  Future<List<ReportModel>> getReports(String? searchQuery) async {
    try {
      print('Getting token...');
      String? token = await LoginServices(Dio()).getToken();
      print('Token received: ${token != null ? 'Yes' : 'No'}');

      print('Making API request to: $baseUrl/reports/admin-reports');
      print(
          'Search query params: ${searchQuery != null && searchQuery.isNotEmpty ? {
              'name': searchQuery
            } : 'none'}');

      final response = await _dio.get(
        '$baseUrl/reports/admin-reports',
        queryParameters: searchQuery != null && searchQuery.isNotEmpty
            ? {'name': searchQuery}
            : null,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final reports = data.map((json) => ReportModel.fromJson(json)).toList();
        print('Parsed ${reports.length} reports successfully');
        return reports;
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      print('Error in getReports: $e');
      throw Exception('Error fetching reports: $e');
    }
  }
}
