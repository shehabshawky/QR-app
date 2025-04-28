import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:login_page/components/my_dropdown_menu.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/components/my_network_product_view.dart';
import 'package:login_page/components/product_categories_chart.dart';
import 'package:login_page/components/geographic_distribution_chart.dart';
import 'package:login_page/components/product_expiration_chart.dart';
import 'package:login_page/components/total_scans_chart.dart';
import 'package:login_page/components/warranty_distribution_chart.dart';
import 'package:login_page/models/utils.dart';
import 'package:login_page/services/login_services.dart';
import 'package:login_page/services/get_product_list_service.dart';
import 'package:login_page/services/admin_analytics_service.dart';
import 'package:login_page/models/productmodel.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:login_page/components/analytics_card.dart';
import 'package:login_page/components/counterfeit_reports_chart.dart';
import 'package:login_page/components/total_revenue_chart.dart';
import 'package:login_page/components/total_lost_revenue_chart.dart';

import '../../consts/consts.dart';

class AdminAnalytics extends StatefulWidget {
  const AdminAnalytics({super.key});

  @override
  State<AdminAnalytics> createState() => _AdminAnalyticsState();
}

class _AdminAnalyticsState extends State<AdminAnalytics> {
  String? _selectedProductId;
  String? _selectedInterval;
  bool show_calendar = false;
  DateTime? startDate;
  DateTime? endDate;
  bool isSelectingStartDate = true;
  Map<String, dynamic>? analyticsData;
  List<Productmodel> products = [];
  bool isLoading = true;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _selectedProductId = 'all';
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      String? token = await LoginServices(_dio).getToken();
      if (token == null) {
        print('No token found');
        return;
      }

      // Fetch products
      products = await GetProductListService(_dio).getproducts(token);

      // Fetch analytics data
      await fetchAnalytics();

      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchAnalytics() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await LoginServices(_dio).getToken();
      if (token == null) {
        print('No token found');
        return;
      }

      final adminAnalyticsService = AdminAnalyticsService(_dio);
      final data = await adminAnalyticsService.getAnalytics(
        productId: _selectedProductId,
        interval: _selectedInterval,
        startDate: startDate,
        endDate: endDate,
        token: token,
      );

      setState(() {
        analyticsData = data;
        print('Selected Product ID: $_selectedProductId');
        print('Response Data: $data'); // Debug print
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching analytics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      if (isSelectingStartDate) {
        startDate = day;
        isSelectingStartDate = false;
      } else {
        if (day.isBefore(startDate!)) {
          // If selected end date is before start date, swap them
          endDate = startDate;
          startDate = day;
        } else {
          endDate = day;
        }
        isSelectingStartDate = true;
        show_calendar = false; // Hide calendar after selecting end date
        fetchAnalytics(); // Fetch new data with updated date range
      }
    });
  }

  Widget buildCalendar() {
    if (!show_calendar) return Container();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        locale: "en_us",
        rowHeight: 43,
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: isSelectingStartDate
            ? (startDate ?? DateTime.now())
            : (endDate ?? DateTime.now()),
        selectedDayPredicate: (day) {
          if (isSelectingStartDate) {
            return startDate != null && isSameDay(startDate!, day);
          } else {
            return endDate != null && isSameDay(endDate!, day);
          }
        },
        onDaySelected: _onDaySelected,
        availableGestures: AvailableGestures.all,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: isSelectingStartDate ? Colors.blue : Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with export button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Mybutton(
                  icon: Icons.cloud_upload_outlined,
                  buttonName: "Export",
                  onPressed: selectinmage,
                  buttonWidth: 120,
                  buttonHeight: 40,
                  buttonColor: MYmaincolor,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filters section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date range selection
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Start: ${startDate?.toString().split(" ")[0]}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "End: ${endDate?.toString().split(" ")[0]}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  buildCalendar(),
                  const SizedBox(height: 16),

                  // Interval dropdown
                  CustomDropdownMenu(
                    label: "Interval",
                    entries: const ["daily", "weekly", "monthly", "yearly"],
                    width: 300,
                    onSelected: (value) {
                      setState(() {
                        _selectedInterval = value;
                        fetchAnalytics();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Products dropdown
                  CustomDropdownMenu(
                    label: "Analytics based on",
                    entries: ['All Products', ...products.map((p) => p.name)],
                    width: 300,
                    onSelected: (value) {
                      setState(() {
                        _selectedProductId = value == 'All Products'
                            ? 'all'
                            : products.firstWhere((p) => p.name == value).id;
                        fetchAnalytics();
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Calendar toggle button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() {
                        show_calendar = !show_calendar;
                        isSelectingStartDate =
                            true; // Reset to start date selection when showing calendar
                      }),
                      icon: const Icon(Icons.date_range),
                      label: Text(
                          show_calendar ? "Hide Calendar" : "Select Dates"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Analytics content
            if (_selectedProductId != null && _selectedProductId != 'all') ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Product',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
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
                              child: products
                                          .firstWhere(
                                              (p) => p.id == _selectedProductId)
                                          .image !=
                                      null
                                  ? Image.network(
                                      products
                                          .firstWhere(
                                              (p) => p.id == _selectedProductId)
                                          .image!,
                                    )
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
                                    products
                                        .firstWhere(
                                            (p) => p.id == _selectedProductId)
                                        .name,
                                    style: const TextStyle(
                                      color: MYmaincolor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    products
                                        .firstWhere(
                                            (p) => p.id == _selectedProductId)
                                        .description,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(
                                      height: 1, color: Color(0xFFE0E0E0)),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    "Release Date",
                                    products
                                        .firstWhere(
                                            (p) => p.id == _selectedProductId)
                                        .release_date,
                                  ),
                                  _buildInfoRow(
                                    "Total Units",
                                    "${products.firstWhere((p) => p.id == _selectedProductId).unitsCount} Units",
                                  ),
                                  _buildInfoRow(
                                    "Scanned",
                                    "${products.firstWhere((p) => p.id == _selectedProductId).scannedUnitsCount} Units",
                                  ),
                                  _buildInfoRow(
                                    "QR Error",
                                    "${products.firstWhere((p) => p.id == _selectedProductId).qrErrorsCount} Units",
                                  ),
                                  _buildInfoRow(
                                    "Warranty Duration",
                                    "${products.firstWhere((p) => p.id == _selectedProductId).warranty_duration} Months",
                                  ),
                                  if (products
                                          .firstWhere(
                                              (p) => p.id == _selectedProductId)
                                          .properties !=
                                      null)
                                    _buildInfoRow(
                                      "Properties",
                                      _formatProperties(products
                                          .firstWhere(
                                              (p) => p.id == _selectedProductId)
                                          .properties),
                                    ),
                                  _buildInfoRow(
                                    "Price",
                                    "EGP ${products.firstWhere((p) => p.id == _selectedProductId).price}",
                                  ),
                                  _buildInfoRow(
                                    "Category",
                                    products
                                        .firstWhere(
                                            (p) => p.id == _selectedProductId)
                                        .category,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            buildAnalyticsContent(),
          ],
        ),
      ),
    );
  }

  Widget buildAnalyticsContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (analyticsData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No data available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final data = analyticsData!['data'] ?? analyticsData;
    final mostScannedProduct = data['most-scanned-product'];
    final mostScannedCounterfeit = data['most-scanned-counterfeit'];
    final warrantyDistribution = data['warranty-distribution'];
    final geographicData = data['geographical-distribution'] as List<dynamic>?;
    final categoryData = data['categories-distribution'] as List<dynamic>?;
    final productsExpirationDate =
        data['products-expiration-date'] as List<dynamic>?;
    final totalScansData = data['total-scans-chart'] as List<dynamic>?;
    final counterfeitReportsData =
        data['counterfeit-reports-chart'] as List<dynamic>?;
    final totalRevenueData = data['total-revenue-chart'] as List<dynamic>?;
    final totalRevenueLostData =
        data['total-revenue-lost-chart'] as List<dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedProductId == 'all' || _selectedProductId == null) ...[
          if (mostScannedProduct != null) ...[
            const Text(
              'Most Scanned Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            MyNetworkProductview(
              image: mostScannedProduct['image'] as String? ?? '',
              name: mostScannedProduct['name'] as String? ?? "Unknown Product",
              scans: mostScannedProduct['scanCount'] as int? ?? 0,
              scanLabel: "Scans",
            ),
          ],
          const SizedBox(height: 24),
          if (mostScannedCounterfeit != null) ...[
            const Text(
              'Most Counterfeited Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            MyNetworkProductview(
              image: mostScannedCounterfeit['image'] as String? ?? '',
              name: mostScannedCounterfeit['name'] as String? ??
                  "Unknown Product",
              scans: mostScannedCounterfeit['counterfeitCount'] as int? ?? 0,
              scanLabel: "Counterfeits",
            ),
          ],
        ],
        const SizedBox(height: 24),
        if (warrantyDistribution != null) ...[
          AnalyticsCard(
            child:
                WarrantyDistributionChart(warrantyData: warrantyDistribution),
          ),
        ],
        const SizedBox(height: 24),
        if (geographicData != null) ...[
          AnalyticsCard(
            child:
                GeographicDistributionChart(distributionData: geographicData),
          ),
        ],
        const SizedBox(height: 24),
        if (categoryData != null) ...[
          AnalyticsCard(
            child: ProductCategoriesChart(categoryData: categoryData),
          ),
        ],
        const SizedBox(height: 24),
        if (productsExpirationDate != null) ...[
          AnalyticsCard(
            child:
                ProductExpirationChart(expirationData: productsExpirationDate),
          ),
        ],
        const SizedBox(height: 24),
        if (totalScansData != null) ...[
          AnalyticsCard(
            child: totalScansChart(totalScans: totalScansData),
          ),
        ],
        const SizedBox(height: 24),
        if (counterfeitReportsData != null) ...[
          AnalyticsCard(
            child: CounterfeitReportsChart(reportsData: counterfeitReportsData),
          ),
        ],
        const SizedBox(height: 24),
        if (totalRevenueData != null) ...[
          AnalyticsCard(
            child: TotalRevenueChart(revenueData: totalRevenueData),
          ),
        ],
        const SizedBox(height: 24),
        if (totalRevenueLostData != null) ...[
          AnalyticsCard(
            child: TotalLostRevenueChart(lostRevenueData: totalRevenueLostData),
          ),
        ],
      ],
    );
  }

  void selectinmage() async {
    File? img = await pickImage();
    setState(() {
      if (img != null) {
        // ignore: unused_local_variable
        var image = img;
      }
    });
  }

  Widget _buildInfoRow(String label, String value) {
    // Extract numbers and units for coloring
    RegExp numberPattern = RegExp(r'(\d+)(\s*(?:Units?|Months?))?');
    Match? match = numberPattern.firstMatch(value);

    if (match != null &&
        (value.contains('Units') || value.contains('Months'))) {
      String number = match.group(1)!;
      String? unit = match.group(2);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$label: ",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: number,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: unit ?? '',
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
          ],
        ),
      );
    }

    // For properties, format them with proper line breaks
    if (label == "Properties") {
      List<String> lines = value.split('; ').map((prop) {
        List<String> parts = prop.split(': ');
        if (parts.length == 2) {
          return "${parts[0]}: ${parts[1]}";
        }
        return prop;
      }).toList();

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$label: ",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: lines
                        .map((line) => Text(
                              line,
                              style: const TextStyle(
                                color: Colors.black87,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
          ],
        ),
      );
    }

    // For other fields (Price, Category, etc.)
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$label: ",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
        ],
      ),
    );
  }

  String _formatProperties(Map<String, dynamic>? properties) {
    if (properties == null) return "No properties";

    List<String> formattedProps = [];
    properties.forEach((key, value) {
      if (value is List) {
        formattedProps.add("$key: ${value.join(', ')}");
      } else {
        formattedProps.add("$key: $value");
      }
    });

    return formattedProps.join(';\n');
  }
}
