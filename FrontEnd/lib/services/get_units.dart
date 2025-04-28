import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/unit_model.dart';

class GetUnits {
  final Dio dio = Dio();

  final List<UnitModel> unitslist = [];
  Future<List<UnitModel>> getAdmins(String? token, String? id,
      {Map<String, dynamic>? queryParams}) async {
    try {
      Response response = await dio.get('$baseUrl/products/units/$id',
          queryParameters: queryParams,
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }));

      List<dynamic> unitsListJson = response.data;
      return unitsListJson.map((item) => UnitModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
