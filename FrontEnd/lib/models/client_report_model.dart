class ClientReportModel {
  final String sku;
  final String status;
  final String productName;

  ClientReportModel({
    required this.sku,
    required this.status,
    required this.productName,
  });

  factory ClientReportModel.fromJson(Map<String, dynamic> json) {
    return ClientReportModel(
      sku: json['sku'] ?? '',
      status: json['status'] ?? '',
      productName: json['productName'] ?? '',
    );
  }
}
