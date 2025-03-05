import 'package:dio/dio.dart';
import 'package:login_page/services/login_services.dart';

class GetSuperadminService {
  Dio dio = Dio();
  GetSuperadminService(this.dio);

  Future<Map<String, dynamic>> getSuperadminInfo() async {
    String? token = await LoginServices(Dio()).getToken();
    Response response =
        await dio.get('http://10.0.2.2:5000/api/users/super_admin_profile',
            options: Options(headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer $token',
            }));
    Map<String, dynamic> jasondata = response.data;

    print(jasondata);
    return jasondata;
  }

}

// options: Options(headers: {
//               "Content-Type": "application/json",
//               'Authorization': 'Bearer ${superadmin['token']}',
//             })