import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
  final Widget child;

  const AnalyticsCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFC4C4C4),
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
} 