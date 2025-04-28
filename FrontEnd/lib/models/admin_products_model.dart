class AdminProduct {
  final String id;
  final String name;

  AdminProduct({
    required this.id,
    required this.name,
  });

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    return AdminProduct(
      id: json['id'],
      name: json['name'],
    );
  }
}

class AdminWithProducts {
  final String adminId;
  final String adminName;
  final List<AdminProduct> products;

  AdminWithProducts({
    required this.adminId,
    required this.adminName,
    required this.products,
  });

  factory AdminWithProducts.fromJson(Map<String, dynamic> json) {
    return AdminWithProducts(
      adminId: json['adminId'],
      adminName: json['adminName'],
      products: (json['products'] as List)
          .map((product) => AdminProduct.fromJson(product))
          .toList(),
    );
  }
}
