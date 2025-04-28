import 'package:dio/dio.dart';
import 'package:login_page/models/client_report_model.dart';
import 'package:login_page/consts/consts.dart';

class ClientReportsService {
  final Dio _dio = Dio();

  Future<List<ClientReportModel>> getClientReports({
    required String? token,
    String? searchTerm,
  }) async {
    try {
      print('Making API request to: $baseUrl/reports/client-reports');
      print('Search term: ${searchTerm ?? "none"}');

      final response = await _dio.get(
        '$baseUrl/reports/client-reports',
        queryParameters: searchTerm != null && searchTerm.isNotEmpty
            ? {'name': searchTerm}
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
        final reports =
            data.map((json) => ClientReportModel.fromJson(json)).toList();
        print('Parsed ${reports.length} reports successfully');
        return reports;
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      print('Error in getClientReports: $e');
      throw Exception('Error fetching reports: $e');
    }
  }
}
