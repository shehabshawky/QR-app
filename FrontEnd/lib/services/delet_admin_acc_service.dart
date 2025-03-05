import 'package:dio/dio.dart';

class DeletAdminAccService {
  Dio dio = Dio();
  DeletAdminAccService({dio});
  void deleteAdminAccount(String? adminid, String? token) async {
       await Dio().delete(
        "http://10.0.2.2:5000/api/users/admin/$adminid",
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
       }));
  }
}
