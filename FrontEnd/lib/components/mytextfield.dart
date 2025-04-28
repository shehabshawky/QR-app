import 'package:flutter/material.dart';
import 'package:login_page/consts/consts.dart';

class MyTextfield extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final controller;
  final String labelText;
  bool? obscureText = false;
  IconButton? suffixIcon;
  double? width;
  int? maxlines;
  int? minlines;
  String? helper;
  TextInputType? keyboardType;
  String? pertext;
  final void Function(String)? onChanged;
  MyTextfield(
      {super.key,
      this.maxlines,
      this.helper,
      this.minlines,
      this.width,
      this.controller,
      this.suffixIcon,
      required this.labelText,
      this.obscureText,
      this.keyboardType,
      this.pertext,
      this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(36, 69, 80, 112).withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(2, 4),
          )
        ],
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: width ?? 350,
        child: TextField(
          keyboardType: keyboardType ?? TextInputType.text,
          minLines: minlines,
          maxLines: maxlines ?? 1,
          controller: controller,
          obscureText: obscureText ?? false,
          decoration: InputDecoration(
            prefixText: pertext ?? "",
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            suffixIcon: suffixIcon,
            suffixIconColor: MYmaincolor,
            border: const OutlineInputBorder(),
            labelText: labelText,
            labelStyle: const TextStyle(color: Color.fromARGB(255, 71, 71, 71)),
            hintText: helper,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
