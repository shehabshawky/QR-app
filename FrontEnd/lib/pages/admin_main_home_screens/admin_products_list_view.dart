import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/components/myproductlistview.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/productmodel.dart';
import 'package:login_page/services/get_product_list_service.dart';
import 'package:login_page/services/login_services.dart';
import 'dart:async';

class AdminProductsListView extends StatefulWidget {
  const AdminProductsListView({super.key});

  @override
  State<AdminProductsListView> createState() => _AdminProductsListViewState();
}

class _AdminProductsListViewState extends State<AdminProductsListView> {
  List<Productmodel> products = [];
  List<Productmodel> filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> getProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await LoginServices(Dio()).getToken();
      List<Productmodel> loadedProducts =
          await GetProductListService(Dio()).getproducts(token);
      setState(() {
        products = loadedProducts;
        filteredProducts = loadedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: ${e.toString()}')),
        );
      }
    }
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProducts = products;
      });
      return;
    }

    setState(() {
      filteredProducts = products.where((product) {
        final name = product.name.toLowerCase();
        final price = product.price.toString();
        final category = product.category.toLowerCase();
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
            price.contains(searchQuery) ||
            category.contains(searchQuery);
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _filterProducts(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Products",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Mybutton(
                  buttonName: '+  Add new product',
                  onPressed: () {
                    Navigator.pushNamed(context, 'addproduct');
                  },
                  buttonWidth: 200,
                  buttonHeight: 40,
                  buttonColor: MYmaincolor,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 300,
              child: MyTextfield(
                controller: _searchController,
                labelText: "Search",
                obscureText: false,
                helper: "Search by name, price, or category",
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProducts.isEmpty
                      ? const Center(child: Text('No products found'))
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Myproductlistview(
                                  productmodel: filteredProducts[index]),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
