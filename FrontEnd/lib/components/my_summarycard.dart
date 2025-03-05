import 'package:flutter/material.dart';

class MySummarycard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final Color percentageColor;
  final IconData icon;

  const MySummarycard({
    super.key,
    required this.title,
    required this.value,
    required this.percentage,
    required this.percentageColor,
    this.icon = Icons.trending_up, // Default icon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(255, 43, 43, 43),
            width: 0.5,
            style: BorderStyle.solid),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 0, 0, 0))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(icon, size: 16, color: percentageColor),
                  const SizedBox(width: 4),
                  Text(
                    percentage,
                    style: TextStyle(
                        color: percentageColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
