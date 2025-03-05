import 'package:flutter/material.dart';
import 'package:login_page/pages/super_mian_home_screens/Super_Admin_Home.dart';
import 'package:login_page/main.dart';
import 'package:login_page/pages/super_mian_home_screens/Super_Admin_profile.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int currentIndex = 0;
  final List<Widget> screens = [
    const SuperAdminHome(),
    const SuperAdminHome(),
    SuperAdminProfile()
  ];
  final keyrefresh = GlobalKey<RefreshIndicatorState>();
  final List<String> navstrings = ["Overview", "Analytics", "Profile"];

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
      ),
      body: Center(
        child: SizedBox(
          width: 850,
          child: ListView(children: <Widget>[
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
            label: 'analytics',
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
