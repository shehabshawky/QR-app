import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/utils.dart';
import 'package:login_page/components/my_dropdown_menu.dart';
import 'package:login_page/services/client_service.dart';
import 'package:login_page/services/login_services.dart';
import 'package:login_page/services/admin_products_service.dart';
import 'package:login_page/models/admin_products_model.dart';

class SubmitReportPage extends StatefulWidget {
  const SubmitReportPage({super.key});

  @override
  State<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends State<SubmitReportPage> {
  ImageData? imageData;
  String? _selectedCompany;
  String? _selectedProduct;
  final ClientService _clientService = ClientService();
  final AdminProductsService _adminProductsService = AdminProductsService();
  final TextEditingController _skuController = TextEditingController();

  String productSku = '';
  List<AdminWithProducts> adminProducts = [];
  List<String> companyNames = [];
  List<AdminProduct> selectedCompanyProducts = [];
  bool isLoading = false;
  bool hasImage = false;
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    fetchAdminProducts();
  }

  Future<void> fetchAdminProducts() async {
    setState(() {
      isLoadingData = true;
    });

    try {
      String? token = await LoginServices(Dio()).getToken();
      adminProducts =
          await _adminProductsService.getAdminProducts(token: token);

      // Extract company names
      companyNames = adminProducts.map((admin) => admin.adminName).toList();

      setState(() {
        isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        isLoadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading companies: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void onCompanySelected(String companyName) {
    setState(() {
      _selectedCompany = companyName;
      _selectedProduct = null; // Reset product selection

      // Find the selected admin and their products
      final selectedAdmin = adminProducts.firstWhere(
        (admin) => admin.adminName == companyName,
        orElse: () => AdminWithProducts(
          adminId: '',
          adminName: '',
          products: [],
        ),
      );

      selectedCompanyProducts = selectedAdmin.products;
    });
  }

  Future<void> submitReport() async {
    if (!hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    if (_skuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a SKU')),
      );
      return;
    }

    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? token = await LoginServices(Dio()).getToken();

      // Find the product ID from the selected product name
      final selectedAdmin = adminProducts.firstWhere(
        (admin) => admin.adminName == _selectedCompany,
        orElse: () => AdminWithProducts(
          adminId: '',
          adminName: '',
          products: [],
        ),
      );

      final selectedProductObj = selectedAdmin.products.firstWhere(
        (product) => product.name == _selectedProduct,
        orElse: () => AdminProduct(id: '', name: ''),
      );

      final response = await _clientService.createReport(
        productID: selectedProductObj.id,
        sku: _skuController.text,
        imageData: imageData,
        token: token,
      );

      if (response.statusCode == 201) {
        // Check if the response is a string or an object
        if (response.data is String) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data.toString()),
              backgroundColor: Colors.green,
            ),
          );
        } else if (response.data is Map) {
          // Handle the new response format with product details
          final responseData = response.data;

          if (responseData['message'] ==
              'QR scanning Error, Original product') {
            // Show success message with product details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${responseData['message']}\nProduct: ${responseData['product']['name']}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );

            // The product is already added to the user's scanned products by the backend
            // No need to do anything else here
          } else {
            // Handle other response formats
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(responseData['message'] ?? response.data.toString()),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        // Navigate back to home screen
        Navigator.popAndPushNamed(context, 'clientHomeScreen');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting report: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Report Product Form"),
        backgroundColor: Colors.white,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 0.5,
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          height: 450,
          margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: Center(
            child: isLoadingData
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: selectinmage,
                            child: Stack(
                              children: [
                                DottedBorder(
                                  dashPattern: const [8, 4],
                                  color: const Color(0xFF9D9D9D),
                                  radius: const Radius.circular(30),
                                  strokeWidth: 2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: hasImage
                                        ? _buildImageWidget()
                                        : const SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add_a_photo,
                                                    size: 40,
                                                    color: Colors.white),
                                                Text(
                                                  "Drop File Here",
                                                  style: TextStyle(
                                                      color: Colors.white),
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
                      MyTextfield(
                        labelText: 'Product SKU',
                        controller: _skuController,
                      ),
                      CustomDropdownMenu(
                        label: 'Manufacturing Company',
                        entries: companyNames,
                        onSelected: (value) {
                          if (value != null) {
                            onCompanySelected(value);
                          }
                        },
                      ),
                      if (_selectedCompany != null)
                        CustomDropdownMenu(
                          label: 'Pick your product',
                          entries: selectedCompanyProducts
                              .map((p) => p.name)
                              .toList(),
                          onSelected: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedProduct = value;
                              });
                            }
                          },
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: MYmaincolor,
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10)),
                            child: Mybutton(
                              buttonName: "Cancel",
                              onPressed: () {
                                Navigator.popAndPushNamed(
                                    context, "clientHomeScreen");
                              },
                              buttonWidth: 150,
                              buttonHeight: 50,
                              textColor: MYmaincolor,
                              buttonColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Mybutton(
                            buttonName: isLoading ? "Submitting..." : "Submit",
                            onPressed: isLoading ? () {} : () => submitReport(),
                            buttonWidth: 150,
                            buttonHeight: 50,
                            buttonColor: MYmaincolor,
                          ),
                        ],
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Helper method to build the appropriate image widget based on platform
  Widget _buildImageWidget() {
    if (kIsWeb) {
      return Image.memory(
        imageData!.bytes!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        imageData!.file!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }

  void selectinmage() async {
    ImageData? img = await pickImageWeb();
    setState(() {
      if (img != null) {
        imageData = img;
        hasImage = true;
      }
    });
  }
}
