import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/components/my_Summarycard.dart';
import 'package:login_page/components/myproductlistview.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/models/analytics_model.dart';
import 'package:login_page/models/productmodel.dart';
import 'package:login_page/services/get_analytics_service.dart';
import 'package:login_page/services/get_product_list_service.dart';
import 'package:login_page/services/login_services.dart';
import 'dart:async';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<Productmodel> products = [];
  int index = 0;
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  AnalyticsModel? analyticsData;
  final GetAnalyticsService _analyticsService = GetAnalyticsService(Dio());

  @override
  void initState() {
    super.initState();
    getProducts();
    _loadAnalytics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    try {
      String? token = await LoginServices(Dio()).getToken();
      if (token != null) {
        final data = await _analyticsService.getAnalytics(
            token, "67f9572d9a7831030a81218d");
        setState(() {
          analyticsData = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> getProducts({String? searchQuery}) async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await LoginServices(Dio()).getToken();
      products = await GetProductListService(Dio())
          .getproducts(token, searchQuery: searchQuery);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onSearchChanged(String query) async {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      getProducts(searchQuery: query);
    });
  }

  Timer? _debounceTimer;

  Widget _buildSummaryCards(bool isDesktop) {
    if (analyticsData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final summaryCards = [
      MySummarycard(
        title: "Total Scans This Month",
        value: "${analyticsData!.currentMonth.totalScans}",
        percentage: "${analyticsData!.changes.totalScans.percentage}%",
        percentageColor: analyticsData!.changes.totalScans.percentage >= 0
            ? Colors.green
            : Colors.red,
        icon: analyticsData!.changes.totalScans.percentage >= 0
            ? Icons.arrow_upward
            : Icons.arrow_downward,
      ),
      MySummarycard(
        title: "Total Revenue This Month",
        value: "£${analyticsData!.currentMonth.totalRevenue}",
        percentage: "${analyticsData!.changes.totalRevenue.percentage}%",
        percentageColor: analyticsData!.changes.totalRevenue.percentage >= 0
            ? Colors.green
            : Colors.red,
        icon: analyticsData!.changes.totalRevenue.percentage >= 0
            ? Icons.arrow_upward
            : Icons.arrow_downward,
      ),
      MySummarycard(
        title: "Total Reports This Month",
        value: "${analyticsData!.currentMonth.totalReports}",
        percentage: "${analyticsData!.changes.totalReports.percentage}%",
        percentageColor: analyticsData!.changes.totalReports.percentage >= 0
            ? Colors.green
            : Colors.red,
        icon: analyticsData!.changes.totalReports.percentage >= 0
            ? Icons.arrow_upward
            : Icons.arrow_downward,
      ),
      MySummarycard(
        title: "Revenue Lost This Month",
        value: "£${analyticsData!.currentMonth.revenueLost}",
        percentage: "${analyticsData!.changes.revenueLost.percentage}%",
        percentageColor: analyticsData!.changes.revenueLost.percentage >= 0
            ? Colors.red
            : Colors.green,
        icon: analyticsData!.changes.revenueLost.percentage >= 0
            ? Icons.arrow_upward
            : Icons.arrow_downward,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: summaryCards
            .map((card) => Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: card,
                )))
            .toList(),
      );
    } else {
      return Column(
        children: summaryCards
            .map((card) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: card,
                ))
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(isDesktop),
              const SizedBox(height: 32),
              Row(
                children: [
                  MyTextfield(
                    controller: _searchController,
                    labelText: "Search",
                    obscureText: false,
                    width: 300,
                    helper: "Name",
                    onChanged: _onSearchChanged,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (products.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: List.generate(
                    products.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Myproductlistview(productmodel: products[index]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
