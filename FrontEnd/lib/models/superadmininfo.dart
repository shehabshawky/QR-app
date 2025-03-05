class Superadmininfo {
  
  String name;
  String email;

  Superadmininfo({
    required this.name,
    required this.email
  });

  factory Superadmininfo.fromJson(Map<String, dynamic> json) {
    return Superadmininfo(
      name: json['name'],
      email: json['email']
    );
  }
}