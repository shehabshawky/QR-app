import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';

class DeletAdminAccService {
  Dio dio = Dio();
  DeletAdminAccService({dio});
  void deleteAdminAccount(String? adminid, String? token) async {
       try {
  await Dio().delete(
   "$baseUrl/users/admin/$adminid",
   options: Options(headers: {
     "Content-Type": "application/json",
     "Authorization": "Bearer $token"
  }));
} catch (e) {
  throw Exception('Error: $e');
}
  }
}
