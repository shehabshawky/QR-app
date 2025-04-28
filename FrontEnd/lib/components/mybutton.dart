import 'package:flutter/material.dart';
import 'package:login_page/consts/consts.dart';


// ignore: must_be_immutable
class Mybutton extends StatelessWidget {
  final String buttonName;
  final VoidCallback onPressed;
  final double buttonWidth;
  final double buttonHeight;
  Color? buttonColor = MYmaincolor;
  Color? textColor;
  IconData? icon;

  Mybutton(
      {super.key,
      required this.buttonName,
      required this.onPressed,
      required this.buttonWidth,
      required this.buttonHeight,
      this.buttonColor,
      this.textColor,
      this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(36, 69, 80, 112).withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 6),
          )
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          side: const BorderSide(
            width: 0,
          ),
          fixedSize: Size(buttonWidth, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: icon != null
            ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Icon(
                  icon!,
                  color: textColor ?? Colors.white,
                ),
                Text(
                  buttonName,
                  style:
                      TextStyle(color: textColor ?? Colors.white, fontSize: 15),
                ),
              ])
            : Text(
                buttonName,
                style:
                    TextStyle(color: textColor ?? Colors.white, fontSize: 15),
              ),
      ),
    );
  }
}
