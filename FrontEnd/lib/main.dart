import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_add_product_screen.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_main_screen.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_profile.dart';
import 'package:login_page/pages/client_main/client_product_view.dart';
import 'package:login_page/pages/super_mian_home_screens/Super_Admin_create_admin_account.dart';
import 'package:login_page/pages/super_mian_home_screens/Super_Admin_profile.dart';
import 'package:login_page/pages/super_mian_home_screens/main_home_screen.dart';
import 'package:login_page/pages/signup.dart';
import 'pages/login.dart';
import 'package:login_page/pages/client_main/client_main_screen.dart';
import 'pages/client_main/client_submit_report.dart';

// ignore: constant_identifier_names

final dio = Dio();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      title: 'QR Code App',
      routes: {
        'LoginPage': (context) => const LoginPage(),
        'SignupPage': (context) => Signup(),
        'superadminmainpage': (context) => const MainHomeScreen(),
        'creatcompanyacc': (context) => SuperAdminCreateAdminAccount(),
        'superadminprofile': (context) => const SuperAdminProfile(),
        'adminmainscreen': (context) => const AdminMainScreen(),
        'adminprofile': (context) => const AdminProfile(),
        'addproduct': (context) => const AdminAddProductScreen(),
        'clientHomeScreen': (context) => const ClientHomeScreen(),
        'clientSubmitReport': (context) => const SubmitReportPage(),
        'clientproductview': (context) => const ClientProductView(),
      },
      initialRoute: 'LoginPage', // new
    );
  }
}
