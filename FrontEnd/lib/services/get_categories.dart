import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';

class GetCategories {
  Dio dio = Dio();
  GetCategories(dio);
 final List<String> _categoriesList = [];
  List<String> t = [];
  Future<List<String>> getcategories(String? token) async {
    try {
      Response response = await dio.get("$baseUrl/products/categories",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }));
      List<dynamic> jasonlist = response.data;
      for (var items in jasonlist) {
        _categoriesList.add(items);
      }
      
      return _categoriesList;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
