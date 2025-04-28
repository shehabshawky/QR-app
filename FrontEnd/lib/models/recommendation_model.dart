import 'package:login_page/models/client_product_list_model.dart';

class RecommendationScore {
  final double similarity;
  final double complementary;
  final double interest;
  final double combined;

  RecommendationScore({
    required this.similarity,
    required this.complementary,
    required this.interest,
    required this.combined,
  });

  factory RecommendationScore.fromJson(Map<String, dynamic> json) {
    return RecommendationScore(
      similarity: double.parse(json['similarity']?.toString() ?? '0.0'),
      complementary: double.parse(json['complementary']?.toString() ?? '0.0'),
      interest: double.parse(json['interest']?.toString() ?? '0.0'),
      combined: double.parse(json['combined']?.toString() ?? '0.0'),
    );
  }
}

class RecommendationModel extends ProductModel {
  final String id;
  final String releaseDate;
  final RecommendationScore scores;

  RecommendationModel({
    required this.id,
    required this.releaseDate,
    required this.scores,
    required String name,
    required double price,
    required int warrantyDuration,
    String? image,
    String? description,
    Map<String, dynamic>? properties,
    String? category,
    int durationLeft = 0,
  }) : super(
          name: name,
          price: price,
          warrantyDuration: warrantyDuration,
          durationLeft: durationLeft,
          image: image,
          description: description,
          properties: properties,
          category: category,
        );

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['_id'],
      releaseDate: json['release_date'],
      scores: RecommendationScore.fromJson(json['scores']),
      name: json['name'],
      price: double.parse(json['price'].toString()),
      warrantyDuration: json['warranty_duration'],
      durationLeft: json['warranty_duration'] ?? 0,
      image: json['image'],
      description: json['description'],
      properties: json['properties'],
      category: json['category'],
    );
  }
}

class RecommendationsResponse {
  final String status;
  final List<RecommendationModel> data;

  RecommendationsResponse({
    required this.status,
    required this.data,
  });

  factory RecommendationsResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationsResponse(
      status: json['status'],
      data: (json['data'] as List)
          .map((item) => RecommendationModel.fromJson(item))
          .toList(),
    );
  }
}
