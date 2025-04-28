import 'package:flutter/material.dart';

/* First of all, these comments are not AI generated
   اما بعد
   Check the class attributes below
   you will find a comment for each property you can use
*/

class ClientList extends StatelessWidget {
  String? image;
  final String name; // Main title
  final String firstText; // First text before the dot
  final String secondText; // Second text before the dot
  final VoidCallback? onPressed; // A function to be called on press
  final Color? firstTextColor; // First Text Color
  final Color? secondTextColor; // Second Text Color
  final Widget? customRightIcon; // Custom right icon to replace chevron

  ClientList(
      {super.key,
      this.image,
      required this.name,
      required this.firstText,
      required this.secondText,
      this.onPressed,
      this.firstTextColor,
      this.secondTextColor,
      this.customRightIcon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(34, 51, 50, 50).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(5, 10),
            )
          ],
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(image ?? "lib/images/stock.jpg"),
                    backgroundColor: const Color.fromARGB(255, 238, 246, 250),
                    radius: 25,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(
                            firstText,
                            style: TextStyle(
                              fontSize: 14,
                              color: firstTextColor ?? Colors.black,
                            ),
                          ),
                          Text(
                            "  ${String.fromCharCode(0x2022)}  ",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            secondText,
                            style: TextStyle(
                              fontSize: 14,
                              color: secondTextColor ?? Colors.black,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const Spacer(flex: 1),
                  IconButton(
                      // This one will be replaced with the product page
                      onPressed: onPressed,
                      icon: customRightIcon ??
                          const Icon(
                            Icons.chevron_right,
                            size: 26,
                          )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
