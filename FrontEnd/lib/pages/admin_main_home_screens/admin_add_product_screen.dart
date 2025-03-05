import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/main.dart';
import 'package:login_page/models/utils.dart';

class AdminAddProductScreen extends StatefulWidget {
  AdminAddProductScreen({super.key});
  @override
  State<AdminAddProductScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AdminAddProductScreen> {
  int _warrantyDuration = 0;
  int propertynum = 1;
  late Uint8List image;
  // List<TextEditingController> myTextfieldslistcontlorer = [controller];
  List<Widget> myTextfieldslist = [
    MyTextfield(
      labelText: "property 1",
      obscureText: false,
      helper: "placholder",
      width: 400,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 850,
          child: ListView(children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          "Add New Product",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: selectinmage,
                          child: Stack(
                            children: [
                              DottedBorder(
                                dashPattern: [8, 4],
                                color: const Color(0xFF9D9D9D),
                                radius: Radius.circular(30),
                                strokeWidth: 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo,
                                            size: 40, color: Colors.white),
                                        Text(
                                          "Drop File Here",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Column(children: [
                          const Text(
                            "Drag image here",
                            style: TextStyle(
                                color: Color(0xFF9D9D9D), fontSize: 15),
                          ),
                          const Text(
                            "or",
                            style: TextStyle(
                                color: Color(0xFF9D9D9D), fontSize: 15),
                          ),
                          TextButton(
                            onPressed: selectinmage,
                            child: const Text(
                              "Browse image",
                              style:
                                  TextStyle(color: MYmaincolor, fontSize: 15),
                            ),
                          ),
                        ])
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    MyTextfield(
                      labelText: "Product name",
                      obscureText: false,
                      width: 400,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: 400,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  const Row(
                                    children: [
                                      Text("Warranty Duration in Months"),
                                    ],
                                  ),
                                  TextField(
                                    controller: TextEditingController(
                                        text: _warrantyDuration.toString()),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        border: InputBorder.none),
                                    onChanged: (value) {
                                      setState(() {
                                        _warrantyDuration =
                                            int.tryParse(value) ?? 0;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.arrow_drop_up),
                                onPressed: () {
                                  setState(() {
                                    _warrantyDuration++;
                                  });
                                },
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.arrow_drop_down),
                                onPressed: () {
                                  setState(() {
                                    if (_warrantyDuration > 0)
                                      _warrantyDuration--;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 400,
                      child: MyTextfield(
                        labelText: "Description",
                        obscureText: false,
                        maxlines: 5,
                        minlines: 5,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Product Properties",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: List.generate(
                          myTextfieldslist.length,
                          (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: myTextfieldslist[index],
                              )),
                    ),
                    Mybutton(
                      buttonName: "+",
                      onPressed: () {
                        propertynum++;
                        setState(() {
                          myTextfieldslist.add(
                            MyTextfield(
                              labelText: "property $propertynum",
                              obscureText: false,
                              helper: "placholder",
                              width: 400,
                            ),
                          );
                        });
                      },
                      buttonWidth: 10,
                      buttonHeight: 10,
                      buttonColor: MYmaincolor,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 350,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: MYmaincolor,
                                    width: 2,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(30)),
                            child: Mybutton(
                              buttonName: "Cancel",
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              buttonWidth: 150,
                              buttonHeight: 50,
                              textColor: MYmaincolor,
                              buttonColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          Mybutton(
                            buttonName: "Add product",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            buttonWidth: 150,
                            buttonHeight: 50,
                            buttonColor: MYmaincolor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  void selectinmage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    setState(() {
      if (img != null) {
        image = img;
      } else {}
    });
  }
}
