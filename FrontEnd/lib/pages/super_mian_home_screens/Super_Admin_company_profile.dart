// ignore: file_names
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/components/myField_display.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/adminslistmodel.dart';
import 'package:login_page/services/delet_admin_acc_service.dart';
import 'package:login_page/services/register_services.dart';

class SuperAdminCompanyProfile extends StatelessWidget {
  final Adminslistmodel company;
  const SuperAdminCompanyProfile({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text(
                    'Delete company ',
                    style: TextStyle(color: Color.fromARGB(255, 180, 39, 39)),
                  ),
                  content: const Text('do you want to delete this company'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel',
                          style: TextStyle(color: MYmaincolor)),
                    ),
                    TextButton(
                      onPressed: () async {
                        String? token = await LoginServices(Dio()).getToken();
                        DeletAdminAccService()
                            .deleteAdminAccount(company.id, token);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('OK',
                          style: TextStyle(
                              color: Color.fromARGB(255, 180, 39, 39))),
                    ),
                  ],
                ),
              ),
              icon: const Icon(
                Icons.delete_forever_outlined,
                size: 34,
                color: Color.fromARGB(255, 180, 39, 39),
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
        title: const Text("Back"),
        titleTextStyle: const TextStyle(color: MYmaincolor, fontSize: 20),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(
                company.image ?? 'https://picsum.photos/250?image=9'),
            // backgroundColor: const Color(0xFFF4F8FA),
            // child: Column(
            //   children: [
            //     Text(
            //       company.name[0],
            //       style: const TextStyle(
            //         fontSize: 100,
            //         color: MYmaincolor,
            //       ),
            //     ),
            //   ],
            // ),
          ),

          const SizedBox(height: 15), // Spacing
          Text(
            company.name,
            style: const TextStyle(
              fontSize: 40,
              color: MYmaincolor,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 60),
          FieldDisplay(label: "Email : ", labelValue: company.email),
          FieldDisplay(
              label: "Number of Products : ",
              labelValue: "${company.productsCount}"),
          FieldDisplay(
              label: "Number of QR Generated : ",
              labelValue: '${company.qRCodesCount}'),
        ],
      ),
    );
  }

  String getimage() {
    return company.image ?? "https://picsum.photos/250?image=9";
  }
}
