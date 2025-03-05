import 'package:flutter/material.dart';

class FieldDisplay extends StatelessWidget {
  final String label;
  final String labelValue;

  const FieldDisplay(
      {super.key, required this.label, required this.labelValue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 60,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 25),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(36, 69, 80, 112).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(5, 10),
            )
          ],
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              // Center text alignment
            ),
            Text(
              labelValue,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xff3B82F6),
              ),
              // Center text alignment
            ),
          ],
        ),
      ),
    );
  }
}
