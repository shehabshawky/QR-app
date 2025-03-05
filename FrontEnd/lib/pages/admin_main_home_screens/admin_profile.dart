// ignore: file_names
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/components/myField_display.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/main.dart';
import 'package:login_page/services/login_services.dart';

class AdminProfile extends StatefulWidget {
  AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _SuperAdminProfileState();
}

class _SuperAdminProfileState extends State<AdminProfile> {
  Map<String, dynamic>? superinfo;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // getsuperonfo();
  }

  // Future<void> getsuperonfo() async {
  //   try {
  //     final data = await GetSuperadminService(Dio()).getSuperadminInfo();
  //     setState(() {
  //       superinfo = data;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = e.toString();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // if (superinfo == null)
          //   _errorMessage.isEmpty
          //       ? const CircularProgressIndicator() // Show loading indicator
          //       : Text(
          //           _errorMessage,
          //           style: const TextStyle(color: Colors.red),
          //         )
          // else
          Column(
            children: [
              CircleAvatar(
                radius: 80,
                backgroundColor: const Color(0xFFF4F8FA),
                child: Column(
                  children: [
                    Text(
                      // superinfo!["name"][0],
                      "A",
                      style: const TextStyle(
                        fontSize: 100,
                        color: MYmaincolor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                // superinfo!["name"],
                'Admin',
                style: const TextStyle(
                  fontSize: 40,
                  color: MYmaincolor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 60),
              FieldDisplay(label: "Email: ", labelValue: "Admin@gmail.com"),
              // superinfo!["email"]
              const SizedBox(height: 40),
              Mybutton(
                buttonName: "Change Password",
                onPressed: () {},
                buttonWidth: 200,
                buttonHeight: 40,
                buttonColor: MYmaincolor,
              ),
              const Text(
                "or ",
                style: TextStyle(fontSize: 20, color: MYmaincolor),
              ),
              Mybutton(
                buttonName: "Log Out",
                onPressed: () {
                  LoginServices(Dio()).deleteToken();
                  Navigator.pushNamed(context, 'LoginPage');
                },
                buttonWidth: 120,
                buttonHeight: 40,
                buttonColor: const Color.fromARGB(255, 110, 17, 17),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
