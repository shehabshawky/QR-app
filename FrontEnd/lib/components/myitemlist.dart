import 'package:flutter/material.dart';

import 'package:login_page/models/adminslistmodel.dart';
import 'package:login_page/pages/super_mian_home_screens/Super_Admin_company_profile.dart';

class Myitemlist extends StatelessWidget {
  Adminslistmodel adminsmodel;
  int index;

  Myitemlist({super.key, required this.adminsmodel, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SuperAdminCompanyProfile(company: adminsmodel)),
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        SuperAdminCompanyProfile(company: adminsmodel)
                                .getimage()),
                    radius: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Text(
                        adminsmodel.name,
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
                        "${adminsmodel.productsCount} products",
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
                        Navigator.pushNamed(
                            context, 'superadmaincompanyprofile');
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
