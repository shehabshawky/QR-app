import 'package:flutter/material.dart';

class Myproductinfolist extends StatelessWidget {
  final String laple;
  final String value;
  const Myproductinfolist(
      {super.key, required this.laple, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$laple : "),
              Text(
                value,
                style: const TextStyle(
                    color: Color(0xFF2E7E4A), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const Divider(
          height: 0.5,
          thickness: 1,
          indent: 0,
          endIndent: 10,
        ),
      ],
    );
  }
}
