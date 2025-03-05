import 'package:flutter/material.dart';

class Productmodel {
  String id;
  String name;
  final String? image;
  int units;
  int price;

  Productmodel({
    this.image,
    required this.id,
    required this.name,
    required this.units,
    required this.price,
  });
}
