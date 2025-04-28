class UnitModel {
  String? sku;
  String? warranty_start_date;
  Map<String, dynamic>? properties;
  String? qr_code;
  String? status;
  String? id;
  UnitModel({
    this.sku,
    this.warranty_start_date,
    this.properties,
    this.qr_code,
    this.status,
    this.id,
  });
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      sku: json["sku"],
      warranty_start_date: json["warranty_start_date"] ?? "No Date Yet",
      properties: json["properties"],
      qr_code: json["qr_code"],
      status: json["status"],
      id: json["_id"],
    );
  }
}
