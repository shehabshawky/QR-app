import 'package:dio/dio.dart';
import 'package:login_page/models/recommendation_model.dart';
import 'package:login_page/services/api_client.dart';
import 'package:login_page/services/base_service.dart';

class ProductRecommendationsService extends BaseService {
  final ApiClient _apiClient = ApiClient();

  Future<RecommendationsResponse> getRecommendations(String productId) async {
    try {
      final response = await _apiClient.dio.get('/recommendations/$productId');

      if (response.statusCode == 200) {
        return RecommendationsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load recommendations');
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
