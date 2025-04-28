import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';

// ignore: camel_case_types
class AdminAcc_Services {
  final Dio dio;

  AdminAcc_Services(this.dio);

  // Reguster api

  Future<String> adminacc(
      {String? name,
      String? email,
      String? password,
      required String? token}) async {
    try {
      Response response = await dio.post(
        '$baseUrl/users/create-admin-account',
        data: {
          "name": name,
          "email": email,
          "password": password,
        },
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        String error = e.response?.data;
        return error;
      } else {
        return "Request Error: $e";
      }
    }
  }
}
