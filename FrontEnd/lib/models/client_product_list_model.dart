class ProductModel {
  String? id;
  String? image;
  String name;
  double price;
  int durationLeft;
  String? description;
  int warrantyDuration;
  Map<String, dynamic>? properties;
  String? category;
  String? sku;

  ProductModel({
    this.id,
    this.image,
    required this.name,
    required this.price,
    required this.durationLeft,
    this.description,
    required this.warrantyDuration,
    this.properties,
    this.category,
    this.sku,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    print("Creating ProductModel from JSON: $json");
    return ProductModel(
      id: json['_id'] ?? json['id'],
      image: json['image'],
      name: json['name'],
      price: double.parse(
          json['price'].toString()), // Ensure proper type conversion
      durationLeft: json['duration_left'],
      description: json['description'],
      warrantyDuration: json['warranty_duration'],
      properties: json['properties'] != null
          ? Map<String, dynamic>.from(json['properties'])
          : null,
      category: json['category'],
      sku: json['sku'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image,
      'name': name,
      'price': price,
      'duration_left': durationLeft,
      'description': description,
      'warranty_duration': warrantyDuration,
      'properties': properties,
      'category': category,
      'sku': sku,
    };
  }

  @override
  String toString() {
    return 'ProductModel{id: $id, image: $image, name: $name, price: $price, durationLeft: $durationLeft, description: $description, warrantyDuration: $warrantyDuration, properties: $properties, category: $category, sku: $sku}';
  }
}
