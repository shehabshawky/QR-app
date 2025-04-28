class Productmodel {
  String id;
  String name;
  final String? image;
  String description;
  String release_date;
  int? warranty_duration;
  dynamic properties;
  String category;
  int unitsCount;
  int scannedUnitsCount;
  int qrErrorsCount;

  String price;
  Productmodel({
    required this.category,
    required this.description,
    required this.properties,
    required this.release_date,
    required this.unitsCount,
    required this.scannedUnitsCount,
    required this.qrErrorsCount,
    this.warranty_duration,
    this.image,
    required this.id,
    required this.name,
    required this.price,
  });

  factory Productmodel.fromJson(Map<String, dynamic> json) {
    return Productmodel(
        category: json["category"],
        description: json["description"],
        properties: json["properties"],
        release_date: json["release_date"],
        unitsCount: json["unitsCount"],
        scannedUnitsCount: json["scannedUnitsCount"],
        qrErrorsCount: json["QRErrorsCount"],
        warranty_duration: json["warranty_duration"],
        id: json["_id"],
        name: json["name"],
        price: json["price"],
        image: json["image"]);
  }
}
