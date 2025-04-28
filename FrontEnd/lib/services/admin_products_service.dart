import 'package:dio/dio.dart';
import 'package:login_page/models/admin_products_model.dart';
import 'api_client.dart';
import 'base_service.dart';

class AdminProductsService extends BaseService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AdminWithProducts>> getAdminProducts({
    String? token,
  }) async {
    try {
      _apiClient.setAuthToken(token);
      final response = await _apiClient.dio.get('/products/admins-products');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => AdminWithProducts.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load admin products. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    }
  }
}
