import 'package:flutter/material.dart';
import 'package:login_page/components/mytextfield.dart';

class AdminViewReports extends StatefulWidget {
  const AdminViewReports({super.key});

  @override
  State<AdminViewReports> createState() => _AdminViewReportsState();
}

class _AdminViewReportsState extends State<AdminViewReports> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "User Reports",
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 20,
        ),
        MyTextfield(
          labelText: 'Search',
          obscureText: false,
          width: 300,
          helper: "Name",
        ),
        const SizedBox(
          height: 20,
        ),
        SingleChildScrollView(
          child: PaginatedDataTable(
            columns: [
              DataColumn(label: Text('SKU'), onSort: (i, b) {}),
              DataColumn(label: Text('product')),
            ],
            source: ReprottData(),
            rowsPerPage: 4, // Set rows per page
          ),
        ),
         const SizedBox(
          height: 20,
        ),
        const Text(
          "User Reports",
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 20,
        ),
        MyTextfield(
          labelText: 'Search',
          obscureText: false,
          width: 300,
          helper: "Name",
        ),
        const SizedBox(
          height: 20,
        ),
        SingleChildScrollView(
          child: PaginatedDataTable(
            columns: [
              DataColumn(label: Text('SKU'), onSort: (i, b) {}),
              DataColumn(label: Text('product')),
            ],
            source: ReprottData(),
            rowsPerPage: 4, // Set rows per page
          ),
        ),
      ],
    );
  }
}

class ReprottData extends DataTableSource {
  final List<Map<String, String>> _data = List.generate(20, (index) {
    return {
      'sku': '#AHGA68',
      'product': 'Tornado microwave',
    };
  });

  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(
          Text(_data[index]['sku']!, style: TextStyle(color: Colors.blue))),
      DataCell(Text(_data[index]['product']!)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
