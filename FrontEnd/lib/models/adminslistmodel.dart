class Adminslistmodel {
  String id;
  String name;
  String? image;
  int productsCount;
  int qRCodesCount;
  String email;
  int scannedUnitsCount;
  int counterfeitReportsCount;

  Adminslistmodel({
    required this.id,
    required this.name,
    this.image,
    required this.productsCount,
    required this.qRCodesCount,
    required this.email,
    required this.scannedUnitsCount,
    required this.counterfeitReportsCount,
  });

  factory Adminslistmodel.fromJson(Map<String, dynamic> json) {
    return Adminslistmodel(
      id: json['id'],
      name: json['name'],
      image: json['icon'],
      productsCount: json['productsCount'] ?? 0,
      qRCodesCount: json['QRCodesCount'] ?? 0,
      email: json['email'],
      scannedUnitsCount: json['scannedUnitsCount'] ?? 0,
      counterfeitReportsCount: json['counterfeitReportsCount'] ?? 0,
    );
  }
}
