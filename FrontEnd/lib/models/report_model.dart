class ReportModel {
  final String sku;
  final String status;
  final String productName;
  final String location;

  ReportModel({
    required this.sku,
    required this.status,
    required this.productName,
    required this.location,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      sku: json['sku'] ?? '',
      status: json['status'] ?? '',
      productName: json['productName'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'status': status,
      'productName': productName,
      'location': location,
    };
  }
}
