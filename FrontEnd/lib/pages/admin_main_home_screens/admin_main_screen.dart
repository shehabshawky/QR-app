import 'package:flutter/material.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_add_product_screen.dart';

import 'package:login_page/main.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_analytics.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_home.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_profile.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_view_product.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_view_reports.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<AdminMainScreen> {
  int currentIndex = 0;
  final List<Widget> screens = [
    AdminHome(),
    AdminAnalytics(),
    AdminViewProduct(),
    AdminViewReports(),
    AdminProfile(),
  ];
  final keyrefresh = GlobalKey<RefreshIndicatorState>();
  final List<String> navstrings = [
    "Overview",
    "Analytics",
    "Products",
    "Reports",
    "Profile"
  ];

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(navstrings.elementAt(currentIndex),
            style: const TextStyle(color: MYmaincolor, fontSize: 30)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                currentIndex = 4;
              });
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: CircleAvatar(
                radius: 18,
                backgroundImage:
                    NetworkImage('https://i.imgur.com/7yqQqkx.jpg'),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 850,
          child: ListView(children: <Widget>[
            const Divider(
              height: 0.5,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            Container(
                margin: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: screens.elementAt(currentIndex))
          ]),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(224, 255, 255, 255),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_gmailerrorred_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: MYmaincolor,
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        iconSize: 32,
      ),
    );
  }
}
