import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/components/my_dropdown_menu.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/components/myproductinfolist.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/productmodel.dart';
import 'package:login_page/models/unit_model.dart';
import 'package:login_page/services/add_unit.dart';
import 'package:login_page/services/get_product_properties.dart';
import 'package:login_page/services/get_units.dart';
import 'package:login_page/services/login_services.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:typed_data';

class AdminViewProduct extends StatefulWidget {
  Productmodel? productinfo;
  AdminViewProduct({super.key, required this.productinfo});

  @override
  State<AdminViewProduct> createState() =>
      _AdminViewProductState(proinf: productinfo);
}

class _AdminViewProductState extends State<AdminViewProduct> {
  Map<String, dynamic>? unitproperties;

  List<UnitModel> units = [];
  final GetUnits _unitsService = GetUnits();
  bool isLoading = true;
  Productmodel? proinf;
  late UnitDataTableSource _dataTableSource;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedAttribute;
  Timer? _debounceTimer;

  _AdminViewProductState({required this.proinf});
  int propertynum = 1;
  List<Widget> droplist = [
    const CustomDropdownMenu(
      label: "property 1",
      entries: [],
      width: 300,
    ),
  ];

  String concat(dynamic properties) {
    if (properties == null) return "No properties";

    if (properties is Map<String, dynamic>) {
      return properties.entries
          .map((e) =>
              '${e.key}: ${e.value is List ? e.value.join(', ') : e.value}')
          .join('; ');
    } else if (properties is List) {
      return properties.join(', ');
    }
    return properties.toString();
  }

  @override
  void initState() {
    super.initState();
    _dataTableSource = UnitDataTableSource(
      units: units,
      context: context,
      refreshCallback: refreshData,
      productId: proinf!.id,
    );
    _loadUnits();
    _getproperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _filterUnits(query);
    });
  }

  Future<void> _filterUnits(String query) async {
    if (query.isEmpty) {
      _loadUnits();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? token = await LoginServices(Dio()).getToken();
      String url = "$baseUrl/products/${proinf!.id}/units";

      Map<String, dynamic> queryParams = {};
      if (_selectedAttribute == null || _selectedAttribute == "SKU") {
        queryParams['sku'] = query;
      } else if (_selectedAttribute == "Warranty") {
        queryParams['warranty'] = query;
      } else if (_selectedAttribute == "Color") {
        queryParams['color'] = query;
      } else if (_selectedAttribute == "Status") {
        queryParams['status'] = query;
      }

      final loadedUnits = await _unitsService.getAdmins(token, proinf?.id,
          queryParams: queryParams);

      setState(() {
        units = loadedUnits;
        _dataTableSource = UnitDataTableSource(
          units: loadedUnits,
          context: context,
          refreshCallback: refreshData,
          productId: proinf!.id,
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching units: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> refreshData() async {
    try {
      setState(() {
        isLoading = true;
      });

      String? token = await LoginServices(Dio()).getToken();
      final loadedUnits = await _unitsService.getAdmins(token, proinf?.id);

      setState(() {
        units = loadedUnits;
        _dataTableSource = UnitDataTableSource(
          units: loadedUnits,
          context: context,
          refreshCallback: refreshData,
          productId: proinf!.id,
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load units: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _getproperties() async {
    try {
      String? token = await LoginServices(Dio()).getToken();
      Map<String, dynamic> properties =
          await GetProductProperties(Dio()).getcategories(token, proinf!.id);
      setState(() {
        unitproperties = properties;
        isLoading = false;
        print(unitproperties);
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load units: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadUnits() async {
    try {
      String? token = await LoginServices(Dio()).getToken();
      final loadedUnits = await _unitsService.getAdmins(token, proinf?.id);
      setState(() {
        units = loadedUnits;
        _dataTableSource = UnitDataTableSource(
          units: loadedUnits,
          context: context,
          refreshCallback: refreshData,
          productId: proinf!.id,
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load units: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleBulkUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected')),
          );
        }
        return;
      }

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      final file = result.files.first;
      final Uint8List? fileBytes = file.bytes;

      if (fileBytes == null) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to read file data')),
          );
        }
        return;
      }

      final excelFile = excel.Excel.decodeBytes(fileBytes);
      final sheet = excelFile.tables[excelFile.tables.keys.first];
      if (sheet == null) throw Exception('No sheet found in Excel file');

      final headers = sheet.rows[0]
          .map((cell) => cell?.value.toString().trim().toLowerCase() ?? '')
          .toList();
      final skuIndex = headers.indexOf('sku');
      final propertiesStartIndex = headers.indexOf('properties');

      if (skuIndex == -1) {
        throw Exception('SKU column not found in Excel file');
      }

      List<Map<String, dynamic>> units = [];
      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row[skuIndex]?.value == null) continue;

        Map<String, dynamic> properties = {};
        if (propertiesStartIndex != -1) {
          for (var j = propertiesStartIndex; j < headers.length; j++) {
            final value = row[j]?.value?.toString();
            if (value != null && value.isNotEmpty) {
              properties[headers[j]] = value;
            }
          }
        }

        units.add({
          "sku": row[skuIndex]!.value.toString(),
          "properties": properties,
        });
      }

      if (units.isEmpty) {
        throw Exception('No valid units found in Excel file');
      }

      String? token = await LoginServices(Dio()).getToken();
      String response = await AddUnit(Dio()).addunit(
        token: token,
        productID: proinf!.id,
        units: units,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response),
            backgroundColor:
                response.contains('success') ? Colors.green : Colors.red,
          ),
        );
        if (response.contains('success')) {
          refreshData();
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (unitproperties == null) {
      return const Center(child: Text("Failed to load properties"));
    }

    List<String> propertiesName = unitproperties!.keys.toList();
    return Scaffold(
      floatingActionButton: Mybutton(
        buttonName: "",
        icon: Icons.refresh,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminViewProduct(
                productinfo: proinf,
              ),
            ),
          );
        },
        buttonWidth: 75,
        buttonHeight: 60,
        buttonColor: MYmaincolor,
      ),
      appBar: AppBar(
        title: const Text("Product Overview"),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Product'),
                  content:
                      Text('Are you sure you want to delete ${proinf!.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  String? token = await LoginServices(Dio()).getToken();
                  final dio = Dio();
                  final response = await dio.delete(
                    '$baseUrl/products/${proinf!.id}',
                    options: Options(headers: {
                      "Authorization": "Bearer $token",
                    }),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  if (response.statusCode == 200) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to delete product'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Error deleting product: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.fromLTRB(20, 40, 20, 0),
        child: ListView(children: [
          const Divider(
            height: 0.5,
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),
          if (isDesktop) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFC4C4C4),
                        style: BorderStyle.solid,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: proinf!.image != null
                        ? Image.network(proinf!.image!)
                        : Image.asset("lib/images/stock.jpg"),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFC4C4C4),
                        style: BorderStyle.solid,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proinf!.name,
                          style: const TextStyle(
                            color: MYmaincolor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          proinf!.description,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Myproductinfolist(
                                    laple: "Release Date",
                                    value: proinf!.release_date,
                                  ),
                                  Myproductinfolist(
                                    laple: "Total Units",
                                    value: "${proinf!.unitsCount} Units",
                                  ),
                                  Myproductinfolist(
                                    laple: "Scanned",
                                    value: "${proinf!.scannedUnitsCount} Units",
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Myproductinfolist(
                                    laple: "QR Error:",
                                    value: "${proinf!.qrErrorsCount} Units",
                                  ),
                                  Myproductinfolist(
                                    laple: "Warranty Duration:",
                                    value:
                                        "${proinf!.warranty_duration} Months",
                                  ),
                                  Myproductinfolist(
                                    laple: "Price",
                                    value: "EGP ${proinf!.price}",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Myproductinfolist(
                          laple: "Properties:",
                          value: concat(proinf!.properties),
                        ),
                        Myproductinfolist(
                          laple: "Category",
                          value: proinf!.category,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Column(
              children: [
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFC4C4C4),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: proinf!.image != null
                        ? Image.network(proinf!.image!)
                        : Image.asset("lib/images/stock.jpg"),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFC4C4C4),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proinf!.name,
                          style: const TextStyle(
                            color: MYmaincolor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          proinf!.description,
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Myproductinfolist(
                          laple: "Release Date",
                          value: proinf!.release_date,
                        ),
                        Myproductinfolist(
                          laple: "Total Units",
                          value: "${proinf!.unitsCount} Units",
                        ),
                        Myproductinfolist(
                          laple: "Scanned",
                          value: "${proinf!.scannedUnitsCount} Units",
                        ),
                        Myproductinfolist(
                          laple: "QR Error:",
                          value: "${proinf!.qrErrorsCount} Units",
                        ),
                        Myproductinfolist(
                          laple: "Warranty Duration:",
                          value: "${proinf!.warranty_duration} Months",
                        ),
                        Myproductinfolist(
                          laple: "Properties:",
                          value: concat(proinf!.properties),
                        ),
                        Myproductinfolist(
                          laple: "Price",
                          value: "EGP ${proinf!.price}",
                        ),
                        Myproductinfolist(
                          laple: "Category",
                          value: proinf!.category,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: MYmaincolor,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Mybutton(
                  buttonName: "ADD NEW UNIT",
                  onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      final skuController = TextEditingController();
                      final propertyControllers = <TextEditingController>[];

                      for (int i = 0; i < unitproperties!.length; i++) {
                        propertyControllers.add(TextEditingController());
                      }

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('ADD NEW UNIT',
                                style: TextStyle(color: MYmaincolor)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MyTextfield(
                                  controller: skuController,
                                  labelText: "Product SKU",
                                  obscureText: false,
                                ),
                                const SizedBox(height: 20),
                                ...List.generate(unitproperties!.length,
                                    (index) {
                                  final propertyName =
                                      unitproperties!.keys.elementAt(index);
                                  final dynamic propertyValue =
                                      unitproperties![propertyName];

                                  List<String> propertyValues = [];

                                  if (propertyValue is List) {
                                    propertyValues = propertyValue
                                        .map((e) => e.toString())
                                        .toList();
                                  } else if (propertyValue is Map) {
                                    propertyValues = propertyValue.values
                                        .map((e) => e.toString())
                                        .toList();
                                  } else {
                                    propertyValues = [propertyValue.toString()];
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: CustomDropdownMenu(
                                            label: propertyName,
                                            entries: propertyValues,
                                            controller:
                                                propertyControllers[index],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel',
                                    style: TextStyle(color: MYmaincolor)),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (skuController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter SKU'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    );

                                    String? token =
                                        await LoginServices(Dio()).getToken();
                                    final Map<String, dynamic> properties = {};

                                    for (int i = 0;
                                        i < unitproperties!.length;
                                        i++) {
                                      final propertyName =
                                          unitproperties!.keys.elementAt(i);
                                      final propertyValue =
                                          propertyControllers[i].text;

                                      if (propertyValue.isNotEmpty) {
                                        properties[propertyName] =
                                            propertyValue;
                                      }
                                    }

                                    debugPrint('Sending unit data:');
                                    debugPrint('SKU: ${skuController.text}');
                                    debugPrint('Properties: $properties');
                                    debugPrint('Product ID: ${proinf!.id}');

                                    String response =
                                        await AddUnit(Dio()).addunit(
                                      token: token,
                                      productID: proinf!.id,
                                      units: [
                                        {
                                          "sku": skuController.text,
                                          "properties": properties
                                        }
                                      ],
                                    );

                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }

                                    if (response == "Unit added successfully") {
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Unit added successfully'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      await _loadUnits();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $response'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }

                                    debugPrint('Error adding unit: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Submit',
                                    style: TextStyle(color: MYmaincolor)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  buttonWidth: 160,
                  buttonHeight: 50,
                  textColor: MYmaincolor,
                  buttonColor: Colors.white,
                ),
              ),
              Mybutton(
                buttonName: "UPLOAD BULK DATA",
                onPressed: _handleBulkUpload,
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
                controller: _searchController,
                labelText: "Search",
                obscureText: false,
                width: 300,
                onChanged: _onSearchChanged,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CustomDropdownMenu(
                label: "Attribute",
                entries: const ["SKU", "Warranty", "Color", "Status"],
                width: 250,
                onSelected: (value) {
                  setState(() {
                    _selectedAttribute = value;
                    if (_searchController.text.isNotEmpty) {
                      _filterUnits(_searchController.text);
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : units.isEmpty
                    ? const Center(child: Text('No units found'))
                    : Container(
                        decoration: BoxDecoration(
                          color: MYmaincolor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dataTableTheme: DataTableThemeData(
                              headingRowColor:
                                  WidgetStateProperty.all(MYmaincolor),
                              headingTextStyle:
                                  const TextStyle(color: Colors.white),
                              dataRowColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  return Colors.white;
                                },
                              ),
                              dividerThickness: 1,
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: PaginatedDataTable(
                              key: ValueKey<int>(units.length),
                              header: const Text(
                                'Product Units',
                                style: TextStyle(color: MYmaincolor),
                              ),
                              columns: const [
                                DataColumn(label: Text('SKU')),
                                DataColumn(label: Text('Warranty Start')),
                                DataColumn(label: Text('Properties')),
                                DataColumn(label: Text('QR Code')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              source: _dataTableSource,
                              rowsPerPage: 5,
                            ),
                          ),
                        ),
                      ),
          ),
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 60,
          ),
        ]),
      ),
    );
  }
}

class UnitDataTableSource extends DataTableSource {
  final List<UnitModel> units;
  final BuildContext context;
  final Future<void> Function() refreshCallback;
  final String productId;

  UnitDataTableSource({
    required this.units,
    required this.context,
    required this.refreshCallback,
    required this.productId,
  });

  Future<void> _deleteUnit({
    String? unitId,
    String? productId,
    String? unitsku,
    String? warranty,
    String? status,
  }) async {
    if (unitId == null || productId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid unit or product ID')),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content:
            Text('Are you sure you want to delete unit ${unitsku ?? 'N/A'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      String? token = await LoginServices(Dio()).getToken();
      final dio = Dio();
      final response = await dio.patch(
        '$baseUrl/products/$productId/deleteUnit/$unitId',
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unit deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await refreshCallback();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete unit'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting unit: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= units.length) return null;
    final unit = units[index];
    return DataRow(
      cells: [
        DataCell(Text(unit.sku ?? 'N/A')),
        DataCell(Text(unit.warranty_start_date ?? 'N/A')),
        DataCell(Text(unit.properties != null
            ? unit.properties!.entries
                .map((entry) => '${entry.key}:${entry.value}')
                .join(', ')
            : "No properties")),
        DataCell(
          unit.qr_code?.isNotEmpty == true
              ? Image.network(
                  unit.qr_code!,
                  width: 60,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                )
              : const Icon(Icons.qr_code_2),
        ),
        DataCell(
          Chip(
            label: Text(
              unit.status ?? "Unknown",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: _getStatusColor(unit.status ?? "Unknown"),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await _deleteUnit(
                unitId: unit.id,
                productId: productId,
                unitsku: unit.sku,
                warranty: unit.warranty_start_date,
                status: unit.status,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => units.length;

  @override
  int get selectedRowCount => 0;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scanned':
        return Colors.green;
      case 'in stock':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}
