import 'package:flutter/material.dart';
import 'package:login_page/main.dart';
import 'package:login_page/models/productmodel.dart';

class Myproductlistview extends StatelessWidget {
  Productmodel productmodel;

  Myproductlistview({
    super.key,
    required this.productmodel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'productview');
      },
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
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(productmodel.image!),
                    radius: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productmodel.name,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "EGP ${productmodel.price} . ${productmodel.units} Units",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                  IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'productview');
                      },
                      icon: const Icon(
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
