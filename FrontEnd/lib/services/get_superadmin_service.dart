import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/services/login_services.dart';

class GetSuperadminService {
  Dio dio = Dio();
  GetSuperadminService(this.dio);

  Future<Map<String, dynamic>> getSuperadminInfo() async {
    try {
      String? token = await LoginServices(Dio()).getToken();
      Response response = await dio.get('$baseUrl/users/profile',
          options: Options(headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $token',
          }));
      Map<String, dynamic> jasondata = response.data;

      return jasondata;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

// options: Options(headers: {
//               "Content-Type": "application/json",
//               'Authorization': 'Bearer ${superadmin['token']}',
//             })
