import 'package:dio/dio.dart';

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
        'http://10.0.2.2:5000/api/users/create-admin-account',
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
