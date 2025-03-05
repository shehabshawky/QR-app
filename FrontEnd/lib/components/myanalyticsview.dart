import 'package:flutter/material.dart';
import 'package:login_page/main.dart';

class Myanalyticsview extends StatelessWidget {
  final String? name;
  final String? image;
  const Myanalyticsview({super.key,this.image,this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: 400,
      decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFC4C4C4),
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
             name!,
              style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Image.asset(
              image!,
              width: 300,
              height: 300,
            ),
          ),
          
          
        ],
      ),
    );
  }
}
