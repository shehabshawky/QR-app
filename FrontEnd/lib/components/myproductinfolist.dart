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
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to top
            children: [
              // Label part
              Text(
                "$laple: ",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // Value part with flexible width
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF2E7E4A),
                    fontWeight: FontWeight.w800,
                  ),
                  softWrap: true, // Enable text wrapping
                  overflow: TextOverflow.visible, // Allow text to expand
                ),
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
