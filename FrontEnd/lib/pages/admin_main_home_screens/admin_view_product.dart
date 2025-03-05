import 'package:flutter/material.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/components/myproductinfolist.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/main.dart';

class AdminViewProduct extends StatefulWidget {
  const AdminViewProduct({super.key});

  @override
  State<AdminViewProduct> createState() => _AdminViewProductState();
}

class _AdminViewProductState extends State<AdminViewProduct> {
  int propertynum = 1;
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
    return Column(
      children: [
        Container(
          width: 400,
          decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFC4C4C4),
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset("lib/images/image.png"),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: 400,
          decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFC4C4C4),
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20)),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TORNADO Microwave",
                  style: TextStyle(
                      color: MYmaincolor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "TORNADO Microwave 36 Litre, 1000 Watt in     Silver Color With Grill, 10 Cooking Menus          MOM-C36BBE-S",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  height: 10,
                ),
                Myproductinfolist(laple: "Release Date", value: "2/7/2022"),
                Myproductinfolist(laple: "Total Units", value: "10,000 Units"),
                Myproductinfolist(laple: "Scanned", value: "8,500 Units"),
                Myproductinfolist(laple: "QR Error:", value: "43 Units"),
                Myproductinfolist(
                    laple: "Warranty Duration:", value: "24 Months"),
                Myproductinfolist(
                    laple: "Properties:",
                    value: "White, Black, Automatic, Manual"),
                Myproductinfolist(laple: "Price", value: "EGP 7,599"),
                Myproductinfolist(laple: "Category", value: "Home Appliances"),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: MYmaincolor, width: 2, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Mybutton(
                buttonName: "ADD NEW UNIT",
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text(
                      'ADD NEW UNIT ',
                      style: TextStyle(color: MYmaincolor),
                    ),
                    content: Column(
                      children: [
                        MyTextfield(
                            labelText: "Product SKU", obscureText: false),
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
                        const SizedBox(
                          height: 20,
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
                                  width: 300,
                                ),
                              );
                            });
                          },
                          buttonWidth: 10,
                          buttonHeight: 10,
                          buttonColor: MYmaincolor,
                        ),
                      ],
                    ),
                   
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel',
                            style: TextStyle(color: MYmaincolor)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: MYmaincolor),
                        ),
                      ),
                    ],
                  ),
                ),
                buttonWidth: 160,
                buttonHeight: 50,
                textColor: MYmaincolor,
              ),
            ),
            Mybutton(
              buttonName: "UPLOAD BULK DATA",
              onPressed: () {},
              buttonWidth: 200,
              buttonHeight: 50,
              buttonColor: MYmaincolor,
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Row(
          children: [
            MyTextfield(
              labelText: "Search",
              obscureText: false,
              width: 300,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            MyTextfield(
              labelText: "Attribute",
              obscureText: false,
              width: 250,
              suffixIcon: IconButton(
                  onPressed: () {}, icon: const Icon(Icons.arrow_drop_down)),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        SingleChildScrollView(
          child: PaginatedDataTable(
            header: Text('Products'),
            columns: [
              DataColumn(label: Text('SKU'), onSort: (i, b) {}),
              DataColumn(label: Text('Warranty Start Date')),
              DataColumn(label: Text('Properties')),
            ],
            source: ProductData(),
            rowsPerPage: 4, // Set rows per page
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class ProductData extends DataTableSource {
  final List<Map<String, String>> _data = List.generate(20, (index) {
    return {
      'sku': '#AHGA68',
      'warrantyDate': '20/01/2021',
      'properties': 'White, Model X'
    };
  });

  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(
          Text(_data[index]['sku']!, style: TextStyle(color: Colors.blue))),
      DataCell(Text(_data[index]['warrantyDate']!)),
      DataCell(Text(_data[index]['properties']!)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
