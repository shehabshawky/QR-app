import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/main.dart';
import 'package:login_page/services/login_services.dart';

class Signup extends StatelessWidget {
  Signup({super.key});
  //controller
  final fullnameCon = TextEditingController();
  final adressCon = TextEditingController();
  final phoneCon = TextEditingController();
  final passCon = TextEditingController();
  final emailCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(children: <Widget>[
          Column(children: [
            // qr code icon

            const SizedBox(
              height: 60,
            ),
            const Icon(
              Icons.qr_code,
              size: 150,
              color: MYmaincolor,
            ),
            //Welcome Back

            const SizedBox(
              height: 20,
            ),
            const Text(
              "Get On Board! ",
              style: TextStyle(
                fontFamily: "Pacifico",
                fontSize: 30,
                color: MYmaincolor,
              ),
            ),
            //Full Name textinput

            const SizedBox(
              height: 20,
            ),
            MyTextfield(
              controller: fullnameCon,
              labelText: "Full Name",
              obscureText: false,
              suffixIcon: const IconButton(
                  onPressed: null, icon: Icon(Icons.person_outline_rounded)),
            ),

            const SizedBox(
              height: 20,
            ),

            MyTextfield(
              labelText: "Adress",
              obscureText: false,
              controller: adressCon,
              suffixIcon: const IconButton(
                  onPressed: null, icon: Icon(Icons.location_city_outlined)),
            ),

            //email textinput

            const SizedBox(
              height: 20,
            ),
            MyTextfield(
              controller: emailCon,
              labelText: "email",
              obscureText: false,
              suffixIcon: const IconButton(
                  onPressed: null, icon: Icon(Icons.email_outlined)),
            ),

            //phonenum textinput
            const SizedBox(
              height: 20,
            ),
            MyTextfield(
              labelText: "Phone No",
              obscureText: false,
              controller: phoneCon,
              suffixIcon:
                  const IconButton(onPressed: null, icon: Icon(Icons.numbers)),
            ),

            //password textinput
            const SizedBox(
              height: 20,
            ),
            MyTextfield(
              labelText: "password",
              obscureText: true,
              controller: passCon,
              suffixIcon: const IconButton(
                  onPressed: null, icon: Icon(Icons.remove_red_eye)),
            ),
            //Already have an Account?

            SizedBox(
              width: 350,
              height: 30,
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Already have an Account?",
                    textAlign: TextAlign.end,
                    style: TextStyle(color: MYmaincolor, fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            //signUp button
            SizedBox(
              width: 350,
              child: Mybutton(
                buttonName: "SignUp",
                onPressed: () async {
                  if (phoneCon.text.isEmpty ||
                      passCon.text.isEmpty ||
                      emailCon.text.isEmpty ||
                      adressCon.text.isEmpty ||
                      fullnameCon.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      backgroundColor: MYmaincolor,
                      content: Text(
                        "Pls fill the remain fields to sinup!",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ));
                  } else {
                    String mass = await LoginServices(Dio()).register(
                        name: fullnameCon.text,
                        email: emailCon.text,
                        password: passCon.text,
                        address: adressCon.text,
                        phone: double.parse(phoneCon.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: MYmaincolor,
                        content: Text(
                          mass,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                      ),
                    );
                    if (mass == "Registered successfully") {
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, 'LoginPage');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: MYmaincolor,
                        content: Text(
                          "Pls enter a valid phone number!",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ));
                    }
                  }
                },
                buttonWidth: 350,
                buttonHeight: 40,
                buttonColor: MYmaincolor,
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
