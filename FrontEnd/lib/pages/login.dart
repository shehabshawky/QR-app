import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/services/login_services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //controller
  final emailCon = TextEditingController();

  final passCon = TextEditingController();

  bool show_password = true;
  Icon show_pass = const Icon(Icons.remove_red_eye_rounded);

  // For decoding JWT

  Future<void> handleLogin() async {
    if (emailCon.text.isEmpty || passCon.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: MYmaincolor,
          content: Text(
            "Pls fill the remain fields to login!",
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      );
    } else {
      Map<String, dynamic> loginResponse = await LoginServices(Dio()).login(
        email: emailCon.text,
        password: passCon.text,
      );
      if (loginResponse["message"] == "Login successful!") {
        String token = loginResponse["token"];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String role = decodedToken['role'];

        if (role == "super_admin") {
          Navigator.pushReplacementNamed(context, 'superadminmainpage');
        } else if (role == 'admin') {
          Navigator.pushReplacementNamed(context, 'adminmainscreen');
        } else if (role == 'client') {
          Navigator.pushReplacementNamed(context, 'clientHomeScreen');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: MYmaincolor,
            content: Text(
              loginResponse["message"],
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(children: <Widget>[
          Column(children: [
            // qr code icon

            const SizedBox(
              height: 100,
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
              "Welcome Back ",
              style: TextStyle(
                fontFamily: "Pacifico",
                fontSize: 30,
                color: MYmaincolor,
              ),
            ),
            //email textinput

            const SizedBox(
              height: 20,
            ),
            MyTextfield(
              controller: emailCon,
              labelText: "email",
              obscureText: false,
              suffixIcon:
                  const IconButton(onPressed: null, icon: Icon(Icons.email)),
            ),

            //password textinput
            const SizedBox(
              height: 20,
            ),
            MyTextfield(
              labelText: "password",
              obscureText: show_password,
              controller: passCon,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    show_password = !show_password;
                  });
                },
                icon: Icon(
                  show_password ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            //forget password
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: 350,
              height: 30,
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  "Forget Password?",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: MYmaincolor,
                      fontFamily: " Pacifico ",
                      fontSize: 15),
                ),
              ),
            ),

            //login button
            Mybutton(
              buttonName: "Login",
              onPressed: handleLogin,
              buttonWidth: 350,
              buttonHeight: 40,
              buttonColor: MYmaincolor,
            ),
            //or
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                "or",
                style: TextStyle(color: MYmaincolor, fontSize: 15),
              ),
            ),

            //sighn up
            Mybutton(
                buttonName: "Signup",
                onPressed: () {
                  Navigator.pushNamed(context, 'SignupPage');
                },
                buttonWidth: 350,
                buttonHeight: 40,
                buttonColor: MYmaincolor),
          ]),
        ]),
      ),
    );
  }
}
