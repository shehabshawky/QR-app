import 'package:flutter/material.dart';
import 'package:login_page/components/my_Summarycard.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/components/myproductlistview.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/main.dart';
import 'package:login_page/models/productmodel.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<Productmodel> products = [
    Productmodel(
        id: "1",
        name: 'TORNADO Microwave',
        price: 10,
        units: 10,
        image: "lib/images/image.png")
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MySummarycard(
          title: "Total Scans This Month",
          value: "1,648",
          percentage: "↑ 168%",
          percentageColor: Colors.green,
          icon: Icons.arrow_upward,
        ),
        MySummarycard(
          title: "Total Revenue This Month",
          value: "£550,000",
          percentage: "↓ 19%",
          percentageColor: Colors.red,
          icon: Icons.arrow_downward,
        ),
        MySummarycard(
          title: "Total Reports This Month",
          value: "550",
          percentage: "↑ 70%",
          percentageColor: Colors.orange,
          icon: Icons.trending_up,
        ),
        MySummarycard(
          title: "Revenue Lost This Month",
          value: "£22,000",
          percentage: "↑ 22.1%",
          percentageColor: Colors.orange,
          icon: Icons.trending_up,
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            MyTextfield(
              labelText: "Search",
              obscureText: false,
              width: 300,
              helper: "Name",
            ),
          ],
        ),
        Mybutton(
          buttonName: "+ Add Product",
          onPressed: () {
            Navigator.pushNamed(context, 'addproduct');
          },
          buttonWidth: 150,
          buttonHeight: 40,
          buttonColor: MYmaincolor,
        ),
        Myproductlistview(productmodel: products[0])
      ],
    );
  }
}
