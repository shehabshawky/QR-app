import 'package:flutter/material.dart';

class Adminslistmodel {
  String id;
  String name;
  ImageProvider? image; 
  int productsCount;
  int qRCodesCount;
  String email;

  Adminslistmodel({
    required this.id,
    required this.name,
    this.image,
    required this.productsCount,
    required this.qRCodesCount,
    required this.email
  });

  factory Adminslistmodel.fromJson(Map<String, dynamic> json) {
    return Adminslistmodel(
      id: json['id'],
      name: json['name'],
      image: json['icon'],
      productsCount: json['productsCount'],
      qRCodesCount: json['QRCodesCount'],
      email: json['email']
    );
  }
}
