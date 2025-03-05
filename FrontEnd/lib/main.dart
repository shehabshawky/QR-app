import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_add_product_screen.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_main_screen.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_profile.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_view_product.dart';
import 'package:login_page/pages/super_mian_home_screens/Super_Admin_create_admin_account.dart';
import 'package:login_page/pages/super_mian_home_screens/Super_Admin_profile.dart';
import 'package:login_page/pages/super_mian_home_screens/main_home_screen.dart';
import 'package:login_page/pages/signup.dart';
import 'pages/login.dart';

// ignore: constant_identifier_names
const Color MYmaincolor = Color(0xFF1E3A8A);
final dio = Dio();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Code App',
      routes: {
        'LoginPage': (context) => const LoginPage(),
        'SignupPage': (context) => Signup(),
        'superadminmainpage': (context) => const MainHomeScreen(),
        'creatcompanyacc': (context) => SuperAdminCreateAdminAccount(),
        'superadminprofile': (context) => SuperAdminProfile(),
        'adminmainscreen': (context) => AdminMainScreen(),
        'adminprofile': (context) => AdminProfile(),
        'addproduct': (context) => AdminAddProductScreen(),
        'productview': (context) => AdminViewProduct(),
      },
      initialRoute:'adminmainscreen' ,
    );
  }
}
