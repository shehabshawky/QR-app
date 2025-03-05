// ignore: file_names
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/components/myitemlist.dart';
import 'package:login_page/main.dart';
import 'package:login_page/services/get_admins_service.dart';
import 'package:login_page/services/login_services.dart';

class SuperAdminHome extends StatefulWidget {
  const SuperAdminHome({super.key});

  @override
  State<SuperAdminHome> createState() => _SuperAdminHomeState();
}

class _SuperAdminHomeState extends State<SuperAdminHome> {
  List<dynamic> adminsList = [];
  bool isLoading = true;
  // Declare the list here
  @override
  void initState() {
    super.initState();
    newMethod();
  }

  Future<void> newMethod() async {
    return await Future.delayed(const Duration(seconds: 0), () async {
      String? token = await LoginServices(Dio()).getToken();
      adminsList = await GetAdminsService().getAdmins(token);
      print(token);
      setState(() {});
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: const CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Mybutton(
                    buttonName: '+  Add new company',
                    onPressed: () {
                      Navigator.pushNamed(context, 'creatcompanyacc');
                    },
                    buttonWidth: 200,
                    buttonHeight: 30,
                    buttonColor: MYmaincolor,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Companies",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    color: Colors.black,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: List.generate(
                  adminsList.length,
                  (index) => Myitemlist(
                    adminsmodel: adminsList[index],
                    index: index,
                  ),
                ),
              ),
            ],
          );
  }
}
