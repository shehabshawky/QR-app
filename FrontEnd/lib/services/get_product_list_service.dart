import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/productmodel.dart';

class GetProductListService {
  Dio dio = Dio();
  GetProductListService(dio);

  Future<List<Productmodel>> getproducts(String? token,
      {String? searchQuery}) async {
    try {
      String url = "$baseUrl/products";
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url += "?name=$searchQuery";
      }

      Response response = await dio.get(url,
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }));

      List<dynamic> jsonList = response.data;
      return jsonList.map((item) => Productmodel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
