import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_analytics.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_home.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_products_list_view.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_profile.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_view_reports.dart';
import 'package:login_page/services/login_services.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<AdminMainScreen> {
  int currentIndex = 0;
  String? profile_image;
  String? userName;
  final List<Widget> screens = [
    const AdminHome(),
    const AdminAnalytics(),
    const AdminProductsListView(),
    const AdminViewReports(),
    const AdminProfile(),
  ];
  final keyrefresh = GlobalKey<RefreshIndicatorState>();
  final List<String> navstrings = [
    "Overview",
    "Analytics",
    "Products",
    "Reports",
    "Profile"
  ];
  Future<void> getUserInfo() async {
    String? token = await LoginServices(Dio()).getToken();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    String image = decodedToken['icon'] ?? "";
    String name = decodedToken['name'] ?? "Admin User";
    setState(() {
      profile_image = image;
      userName = name;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isDesktop
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AppBar(
                  title: Text(navstrings.elementAt(currentIndex),
                      style: const TextStyle(color: MYmaincolor, fontSize: 30)),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  actions: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = 4;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(profile_image ?? ""),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: isDesktop
          ? null
          : Mybutton(
              buttonName: "",
              icon: Icons.refresh,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminMainScreen(),
                  ),
                );
              },
              buttonWidth: 75,
              buttonHeight: 60,
              buttonColor: MYmaincolor,
            ),
      body: isDesktop
          ? Row(
              children: [
                Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: Colors.black12,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      const Icon(
                        Icons.admin_panel_settings,
                        size: 60,
                        color: MYmaincolor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Admin Panel",
                        style: TextStyle(
                          color: MYmaincolor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ...List.generate(
                        navstrings.length,
                        (index) => InkWell(
                          onTap: () => _onItemTapped(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            color: currentIndex == index
                                ? MYmaincolor.withOpacity(0.1)
                                : Colors.transparent,
                            child: Row(
                              children: [
                                Icon(
                                  index == 0
                                      ? Icons.home_outlined
                                      : index == 1
                                          ? Icons.analytics_outlined
                                          : index == 2
                                              ? Icons.inventory_2_outlined
                                              : index == 3
                                                  ? Icons
                                                      .report_gmailerrorred_outlined
                                                  : Icons.person_outline,
                                  color: currentIndex == index
                                      ? MYmaincolor
                                      : Colors.black,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  navstrings[index],
                                  style: TextStyle(
                                    color: currentIndex == index
                                        ? MYmaincolor
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: AppBar(
                          title: Text(
                            navstrings[currentIndex],
                            style: const TextStyle(
                              color: MYmaincolor,
                              fontSize: 30,
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          centerTitle: false,
                          automaticallyImplyLeading: false,
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              onPressed: () {
                                // Handle notifications
                              },
                              color: Colors.black54,
                              iconSize: 24,
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      currentIndex =
                                          4; // Switch to profile page
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundImage:
                                            NetworkImage(profile_image ?? ""),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        userName ?? "Admin User",
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: screens[currentIndex],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : screens[currentIndex],
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
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
