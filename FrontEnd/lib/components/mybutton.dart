import 'package:flutter/material.dart';
import 'package:login_page/main.dart';

// ignore: must_be_immutable
class Mybutton extends StatelessWidget {
  final String buttonName;
  final VoidCallback onPressed;
  final double buttonWidth;
  final double buttonHeight;
  Color? buttonColor = MYmaincolor;
  Color? textColor;

  Mybutton(
      {super.key,
      required this.buttonName,
      required this.onPressed,
      required this.buttonWidth,
      required this.buttonHeight,
      this.buttonColor,
      this.textColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(36, 69, 80, 112).withOpacity(0.4),
          spreadRadius: 1,
          blurRadius: 20,
          offset: const Offset(5, 10),
        )
      ]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            fixedSize: Size(buttonWidth, buttonHeight)),
        onPressed: onPressed,
        child: Text(
          buttonName,
          style: TextStyle(color: textColor ?? Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}
