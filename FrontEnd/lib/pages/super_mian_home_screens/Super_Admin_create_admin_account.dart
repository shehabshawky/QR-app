// ignore: file_names
// ignore: file_names
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/services/create__admin_acc_service.dart';
import 'package:login_page/services/login_services.dart';

class SuperAdminCreateAdminAccount extends StatelessWidget {
  SuperAdminCreateAdminAccount({super.key});
  final companyname = TextEditingController();
  final companyemail = TextEditingController();
  final companypass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Title(
            color: MYmaincolor,
            child: const Text("Back",
                style: TextStyle(color: MYmaincolor, fontSize: 20))),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          width: 500,
          child: ListView(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: const Text(
                      "Create admin account",
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MyTextfield(
                    labelText: "Name",
                    obscureText: false,
                    controller: companyname,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MyTextfield(
                    labelText: "Email",
                    obscureText: false,
                    controller: companyemail,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MyTextfield(
                    labelText: "Password",
                    obscureText: true,
                    controller: companypass,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Mybutton(
                        buttonName: "Create account",
                        onPressed: () async {
                          if (companyname.text.isEmpty ||
                              companyemail.text.isEmpty ||
                              companypass.text.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    backgroundColor: MYmaincolor,
                                    content: Text(
                                      "Please fill all fields",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    )));
                          } else {
                            String? token =
                                await LoginServices(Dio()).getToken();
                            String massage = await AdminAcc_Services(Dio())
                                .adminacc(
                                    name: companyname.text,
                                    email: companyemail.text,
                                    password: companypass.text,
                                    token: token);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: MYmaincolor,
                                content: Text(
                                  massage,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ),
                            );
                            if (massage ==
                                "Admin account created successfully") {
                              Navigator.pop(context);
                            }
                          }
                        },
                        buttonWidth: 200,
                        buttonHeight: 30,
                        buttonColor: MYmaincolor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
