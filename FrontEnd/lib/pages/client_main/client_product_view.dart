import 'package:flutter/material.dart';
import 'package:login_page/components/my_product_slider.dart';
import 'package:login_page/components/myproductinfolist.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/client_product_list_model.dart';
import 'package:login_page/models/recommendation_model.dart';
import 'package:login_page/services/product_recommendations_service.dart';

class ClientProductView extends StatefulWidget {
  final ProductModel? product;

  const ClientProductView({
    super.key,
    this.product,
  });

  @override
  State<ClientProductView> createState() => _ClientProductViewState();
}

class _ClientProductViewState extends State<ClientProductView> {
  bool _isLoadingRecommendations = false;
  List<RecommendationModel>? _recommendations;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print(
        "CllientProductVeiw initState - product: ${widget.product?.name ?? 'null'}");

    if (widget.product != null) {
      _fetchRecommendations();
    }
  }

  Future<void> _fetchRecommendations() async {
    if (widget.product == null) return;

    setState(() {
      _isLoadingRecommendations = true;
      _errorMessage = null;
    });

    try {
      // Use the product's ID from the model
      final productId = widget.product!.id;

      if (productId == null) {
        throw Exception("Product ID is missing");
      }

      final recommendationsService = ProductRecommendationsService();
      final response =
          await recommendationsService.getRecommendations(productId);

      setState(() {
        _recommendations = response.data;
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingRecommendations = false;
      });
      print("Error fetching recommendations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool desktop = isDesktop(context);
    print(
        "CllientProductVeiw build - product: ${widget.product?.name ?? 'null'}");

    // If no product is provided, show a placeholder or error message
    if (widget.product == null) {
      print("Product is null in CllientProductVeiw");
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Product Overview',
            style: TextStyle(color: MYmaincolor, fontSize: 27),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                'No product details available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'There is a problem with retrieving the product details',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MYmaincolor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.product!.name,
          style: TextStyle(color: MYmaincolor, fontSize: desktop ? 30 : 27),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(
              height: 0.5,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            desktop ? _buildDesktopLayout() : _buildMobileLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        children: [
          _buildProductImage(width: 400),
          const SizedBox(height: 20),
          _buildProductDetails(width: 400),
          const SizedBox(height: 20),
          _buildRecommendationsSection(height: 580, width: 400),
          const SizedBox(height: 50)
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    // Calculate a suitable width for desktop - around 60% of screen width
    final desktopWidth = MediaQuery.of(context).size.width * 0.6;

    return Container(
      margin: const EdgeInsets.fromLTRB(40, 40, 40, 0),
      child: Column(
        children: [
          _buildProductImage(width: desktopWidth),
          const SizedBox(height: 30),
          _buildProductDetails(width: desktopWidth),
          const SizedBox(height: 30),
          _buildRecommendationsSection(
              height: 600, width: desktopWidth, isFullWidth: false),
          const SizedBox(height: 50)
        ],
      ),
    );
  }

  Widget _buildProductImage({required double width}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 168, 167, 167),
            style: BorderStyle.solid,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFFFF2E6).withOpacity(0.3)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: isDesktop(context)
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 450),
                  child: Image.network(
                    widget.product!.image ?? "lib/images/image.png",
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset("lib/images/image.png");
                    },
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : Image.network(
                widget.product!.image ?? "lib/images/image.png",
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset("lib/images/image.png");
                },
                fit: BoxFit.contain,
              ),
      ),
    );
  }

  Widget _buildProductDetails({required double width}) {
    bool isActive = widget.product!.durationLeft > 0;

    return Container(
      width: width,
      padding: isDesktop(context)
          ? const EdgeInsets.symmetric(vertical: 10, horizontal: 20)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFC4C4C4),
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product!.name,
              style: const TextStyle(
                  color: MYmaincolor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16), // Increased spacing
            Text(
              widget.product!.description ?? "No description available",
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 24), // Increased spacing

            // Warranty info - centered
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isActive ? "Warranty Active" : "Warranty Expired",
                    style: TextStyle(
                        color: isActive ? const Color(0xFF2E7E4A) : Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${widget.product!.durationLeft.abs()} Months ${isActive ? 'Left' : 'Ago'}",
                    style: TextStyle(
                        color: isActive ? const Color(0xFF2E7E4A) : Colors.red,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 16), // Increased spacing
            // Product information list
            Myproductinfolist(
                laple: "Warranty Duration",
                value: "${widget.product!.warrantyDuration} Months"),
            Myproductinfolist(
                laple: "Properties",
                value: _formatProperties(widget.product!.properties) ??
                    "No properties available"),
            Myproductinfolist(
                laple: "Price",
                value:
                    "EGP ${widget.product!.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}"),
            Myproductinfolist(
                laple: "Category",
                value: widget.product!.category ?? "Uncategorized"),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection({
    required double height,
    required double width,
    bool isFullWidth = false,
  }) {
    final bool desktop = isDesktop(context);

    return Container(
      // Increase height slightly to fix overflow
      height: desktop ? 570 : 500,
      width: width,
      decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 168, 167, 167),
            style: BorderStyle.solid,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(left: 20, bottom: 10),
            child: const Text(
              "Recommended Similar Products",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
            ),
          ),
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Error loading recommendations: $_errorMessage",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else if (!_isLoadingRecommendations &&
              (_recommendations == null || _recommendations!.isEmpty))
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "No suggested products yet",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Padding(
                // Add small bottom padding to fix overflow
                padding: const EdgeInsets.only(bottom: 4),
                child: MyProductSlider(
                  recommendations: _recommendations,
                  isLoading: _isLoadingRecommendations,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatProperties(Map<String, dynamic>? properties) {
    if (properties == null) return "No properties available";

    List<String> formattedProps = [];
    properties.forEach((key, value) {
      if (value is List) {
        formattedProps.add("$key: ${value.join(", ")}");
      } else {
        formattedProps.add("$key: $value");
      }
    });

    return formattedProps.isEmpty
        ? "No properties available"
        : formattedProps.join("\n");
  }
}
