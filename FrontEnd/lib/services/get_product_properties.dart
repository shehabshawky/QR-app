import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';


class GetProductProperties {
  Dio dio = Dio();
  GetProductProperties(dio);

  Future<Map<String,dynamic>> getcategories(String? token , String productid) async {
    try {
      Response response = await dio.get("$baseUrl/products/properties/$productid",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }));
      Map<String,dynamic> jasonlist = response.data;
      return jasonlist;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
