import 'package:flutter/material.dart';
import 'package:login_page/consts/consts.dart';


class Myproductview extends StatelessWidget {
  final String? name;
  final String? image;
  final int? scans;
  const Myproductview({super.key,this.image,this.name,this.scans});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            "Most Scanned Product",
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
             name!,
              style: const TextStyle(
                  color: MYmaincolor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Image.asset(
              image!,
              width: 200,
              height: 110,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Center(
            child: Text(
              "$scans Scans",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
