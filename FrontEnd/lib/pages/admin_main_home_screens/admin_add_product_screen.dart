import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:login_page/components/my_dropdown_menu.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/services/create_product_service.dart';
import 'package:login_page/services/get_categories.dart';
import 'package:login_page/services/login_services.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});
  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final productName = TextEditingController();
  final description = TextEditingController();
  final warranty = TextEditingController();
  final price = TextEditingController();
  final int _warrantyDuration = 0;
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  // Image handling for both web and mobile
  File? _imageFile;
  Uint8List? _webImage;
  bool get hasImage => _imageFile != null || _webImage != null;

  // For properties (key-value pairs)
  final List<MapEntry<String, List<String>>> properties = [];
  final TextEditingController _propertyKeyController = TextEditingController();
  final TextEditingController _propertyValueController =
      TextEditingController();

  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  Future<void> getCategories() async {
    final token = await LoginServices(Dio()).getToken();
    final response = await GetCategories(Dio()).getcategories(token);
    setState(() => categories = response);
  }

  @override
  void dispose() {
    productName.dispose();
    description.dispose();
    warranty.dispose();
    price.dispose();
    _dateController.dispose();
    _propertyKeyController.dispose();
    _propertyValueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _addProperty() {
    final key = _propertyKeyController.text.trim();
    final values = _propertyValueController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (key.isNotEmpty && values.isNotEmpty) {
      setState(() {
        properties.add(MapEntry(key, values));
        _propertyKeyController.clear();
        _propertyValueController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both key and values'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeProperty(int index) {
    setState(() => properties.removeAt(index));
  }

  Future<void> selectImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
          _webImage = null;
        });
      }
    }
  }

  Widget _buildImagePreview() {
    if (!hasImage) {
      return const Center(child: Icon(Icons.add_a_photo, size: 50));
    }

    if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!,
          fit: BoxFit.cover, width: double.infinity);
    }

    return Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity);
  }

  Future<String> handladdingproduct() async {
    if (_dateController.text.isEmpty ||
        warranty.text.isEmpty ||
        price.text.isEmpty ||
        description.text.isEmpty ||
        productName.text.isEmpty ||
        !hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields!'),
          backgroundColor: Colors.red,
        ),
      );
      return "";
    }

    final token = await LoginServices(Dio()).getToken();

    final Map<String, List<String>> propertiesMap = {
      for (final entry in properties) entry.key: entry.value
    };
    final String propertiesJson = jsonEncode(propertiesMap);

    try {
      final response = await CreateProductService(Dio()).setProduct(
        token: token,
        name: productName.text,
        price: price.text,
        warranty_duration: warranty.text,
        description: description.text,
        category: "Electronics",
        release_date: _dateController.text,
        image: kIsWeb ? _webImage : _imageFile,
        properties: propertiesJson,
      );

      if (response == "Product Added successfully") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        return response;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response),
            backgroundColor: Colors.red,
          ),
        );
        return "";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMobile)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: selectImage,
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _buildImagePreview(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      MyTextfield(
                        controller: productName,
                        labelText: "Product Name",
                      ),
                      const SizedBox(height: 15),
                      MyTextfield(
                        controller: price,
                        labelText: "Price",
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),
                      MyTextfield(
                        controller: warranty,
                        labelText: "Warranty (months)",
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),
                      MyTextfield(
                        labelText: 'Release Date',
                        controller: _dateController,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomDropdownMenu(
                        label: "Category",
                        entries: categories,
                      ),
                      const SizedBox(height: 15),
                      MyTextfield(
                        controller: description,
                        labelText: "Description",
                        maxlines: 3,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Properties",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: MyTextfield(
                                  controller: _propertyKeyController,
                                  labelText: "Property Key (e.g., color)",
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: MyTextfield(
                                  controller: _propertyValueController,
                                  labelText: "Values (comma-separated)",
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addProperty,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: selectImage,
                              child: Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _buildImagePreview(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            MyTextfield(
                              controller: productName,
                              labelText: "Product Name",
                            ),
                            const SizedBox(height: 15),
                            MyTextfield(
                              controller: price,
                              labelText: "Price",
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 15),
                            MyTextfield(
                              controller: warranty,
                              labelText: "Warranty (months)",
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            MyTextfield(
                              labelText: 'Release Date',
                              controller: _dateController,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(context),
                              ),
                            ),
                            const SizedBox(height: 15),
                            CustomDropdownMenu(
                              label: "Category",
                              entries: categories,
                            ),
                            const SizedBox(height: 15),
                            MyTextfield(
                              controller: description,
                              labelText: "Description",
                              maxlines: 3,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Properties",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: MyTextfield(
                                        controller: _propertyKeyController,
                                        labelText: "Property Key (e.g., color)",
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: MyTextfield(
                                        controller: _propertyValueController,
                                        labelText: "Values (comma-separated)",
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: _addProperty,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                ...properties.map((entry) => ListTile(
                      title: Text("${entry.key}: ${entry.value.join(', ')}"),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _removeProperty(properties.indexOf(entry)),
                      ),
                    )),
                const SizedBox(height: 30),
                Center(
                  child: Mybutton(
                    buttonName: "Add Product",
                    onPressed: handladdingproduct,
                    buttonWidth: 200,
                    buttonHeight: 50,
                    buttonColor: MYmaincolor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
