import 'package:flutter/material.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/pages/super_mian_home_screens/Super_Admin_Home.dart';
import 'package:login_page/pages/super_mian_home_screens/Super_Admin_profile.dart';
import 'package:login_page/pages/super_mian_home_screens/Super_Admin_Logs.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int currentIndex = 0;
  final List<Widget> screens = [
    const SuperAdminHome(),
    const SuperAdminLogs(),
    const SuperAdminProfile()
  ];
  final keyrefresh = GlobalKey<RefreshIndicatorState>();
  final List<String> navstrings = ["Overview", "Logs", "Profile"];

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isDesktop
          ? AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    navstrings.elementAt(currentIndex),
                    style: const TextStyle(
                      color: MYmaincolor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Stack(
                          children: [
                            const Icon(Icons.notifications_outlined, size: 28),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                child: const Text(
                                  '3',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          // Handle notification press
                        },
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: MYmaincolor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'lib/images/profile.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : AppBar(
              surfaceTintColor: Colors.transparent,
              title: Text(navstrings.elementAt(currentIndex),
                  style: const TextStyle(color: MYmaincolor, fontSize: 30)),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
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
                  label: 'Logs',
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

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
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
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo or Title
              const Column(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: MYmaincolor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Super Admin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MYmaincolor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Navigation Items
              ...List.generate(
                navstrings.length,
                (index) => _buildNavItem(index),
              ),
            ],
          ),
        ),
        // Main Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(24),
            child: screens.elementAt(currentIndex),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? MYmaincolor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: MYmaincolor.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              _getIcon(index),
              color: isSelected ? MYmaincolor : Colors.black54,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              navstrings[index],
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? MYmaincolor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.analytics_outlined;
      case 2:
        return Icons.person_outline;
      default:
        return Icons.error_outline;
    }
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SizedBox(
        width: 850,
        child: ListView(children: <Widget>[
          Container(
              margin: const EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: screens.elementAt(currentIndex))
        ]),
      ),
    );
  }
}
