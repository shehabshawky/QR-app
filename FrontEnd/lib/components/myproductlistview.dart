import 'package:flutter/material.dart';
import 'package:login_page/models/productmodel.dart';
import 'package:login_page/pages/admin_main_home_screens/admin_view_product.dart';

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
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AdminViewProduct(
                    productinfo: productmodel,
                  )),
        );
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    foregroundImage: productmodel.image != null
                        ? NetworkImage(productmodel.image!)
                        : const AssetImage('lib/images/image.png'),
                    radius: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 230,
                          maxHeight: 40,
                        ),
                        child: Text(
                          productmodel.name,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "EGP ${productmodel.price} . ${productmodel.unitsCount} Units",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                  IconButton(
                      onPressed: () {},
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
