import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginServices {
  Dio dio = Dio(BaseOptions(responseType: ResponseType.plain));

  LoginServices(this.dio);

  // Reguster api

  Future<String> register(
      {String? name,
      String? email,
      String? password,
      double? phone,
      String? address}) async {
    try {
      Response response = await dio.post(
        'http://10.0.2.2:5000/api/users/register',
        data: {
          "name": name,
          "email": email,
          "password": password,
          " phone_number": phone,
          "address": address
        },
        options: Options(headers: {"Content-Type": "application/json"}),
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

// login api
    Future<Map<String, dynamic>> login({String? email, String? password}) async {
  try {
    Response response = await dio.post(
      'http://10.0.2.2:5000/api/users/login',
      data: {"email": email, "password": password},
      options: Options(headers: {"Content-Type": "application/json"}),
    );

    if (response.statusCode == 200) {
      String token = response.data['token'];
      await _saveToken(token);
      return {
        "message": "Login successful!",
        "token": token,
        // Assuming the API returns user data
      };
    } else {
      return {"message": "Invalid email or password"};
    }
  } on DioException catch (e) {
    if (e.response != null) {
      return {"message": e.response?.data ?? "An error occurred"};
    } else {
      return {"message": "Request Error: ${e.message}"};
    }
  }
}

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
