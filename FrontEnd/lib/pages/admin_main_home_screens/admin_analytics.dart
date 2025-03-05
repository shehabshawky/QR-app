import 'package:flutter/material.dart';
import 'package:login_page/components/myanalyticsview.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/components/myproductview.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/main.dart';

class AdminAnalytics extends StatefulWidget {
  const AdminAnalytics({super.key});

  @override
  State<AdminAnalytics> createState() => _AdminAnalyticsState();
}

class _AdminAnalyticsState extends State<AdminAnalytics> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Mybutton(
          buttonName: "Export",
          onPressed: () {},
          buttonWidth: 100,
          buttonHeight: 40,
          buttonColor: MYmaincolor,
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {},
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text("Jan 25, 2026 - Dec 25, 2026"),
                  ),
                ],
              ),
            ),
            Mybutton(
              buttonName: "Filter",
              onPressed: () {},
              buttonWidth: 100,
              buttonHeight: 45,
              buttonColor: Colors.black,
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Center(
          child: MyTextfield(
            helper: "ALL Product",
            labelText: "Analytics based on",
            obscureText: false,
            suffixIcon: IconButton(
              onPressed: () {},
              icon: Icon(Icons.arrow_drop_down_outlined),
            ),
            width: 200,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Myproductview(
          image: "lib/images/image.png",
          name: "TORNADO Microwave",
          scans: 8500,
        ),
        const SizedBox(
          height: 20,
        ),
        Myproductview(
          image: 'lib/images/Image (1).png',
          name: "TORNADO Automatic Coffee Maker",
          scans: 650,
        ),
        const SizedBox(
          height: 20,
        ),
        Myanalyticsview(
          image: 'lib/images/BarLineChart.png',
          name: "Scanned Products Categories",
        ),
        const SizedBox(
          height: 20,
        ),
        Myanalyticsview(
          image: 'lib/images/MainChart.png',
          name: "Geographical Distribution",
        ),
        const SizedBox(
          height: 20,
        ),
        Myanalyticsview(
          image: 'lib/images/Chart&Axis.png',
          name: "Total Scans Chart",
        ),
        const SizedBox(
          height: 20,
        ),
        Myanalyticsview(
          image: 'lib/images/pie1.png',
          name: "Warranty Distribution",
        ),
        const SizedBox(
          height: 20,
        ),
        Myanalyticsview(
          image: 'lib/images/MainChart.png',
          name: "Products Expiration Date",
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }
}
