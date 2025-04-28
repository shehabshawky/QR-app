import 'package:flutter/material.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/models/report_model.dart';
import 'package:login_page/services/get_reports.dart';
import 'package:login_page/consts/consts.dart';

class AdminViewReports extends StatefulWidget {
  const AdminViewReports({super.key});

  @override
  State<AdminViewReports> createState() => _AdminViewReportsState();
}

class _AdminViewReportsState extends State<AdminViewReports> {
  final TextEditingController _searchController = TextEditingController();
  final GetReportsService _reportsService = GetReportsService();
  List<ReportModel> reports = [];
  bool isLoading = true;
  String? error;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    print('Initializing AdminViewReports...');
    _loadReports();
  }

  Future<void> _loadReports() async {
    print('Loading reports... Search query: $_searchQuery');
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await _reportsService.getReports(_searchQuery);
      print('Reports received: ${response.length} items');

      if (!mounted) return;

      setState(() {
        reports = response;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      print('Error loading reports: $e');
      if (!mounted) return;

      setState(() {
        error = e.toString();
        isLoading = false;
        reports = [];
      });
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading reports...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReports,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (reports.isEmpty) {
      return const Center(
        child: Text(
          'No reports found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.of(context).size.width < 600
              ? 600
              : MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: MYmaincolor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'SKU',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Product Name',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Location',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: reports
                        .map((report) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFEEEEEE),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      report.sku,
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      report.productName,
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      width: 100,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      margin: const EdgeInsets.only(right: 24),
                                      decoration: BoxDecoration(
                                        color: report.status.toLowerCase() ==
                                                'counterfeit'
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        report.status,
                                        style: TextStyle(
                                          color: report.status.toLowerCase() ==
                                                  'counterfeit'
                                              ? Colors.red
                                              : Colors.green,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      report.location,
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            const Text(
              "Reports Overview",
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 300,
              child: MyTextfield(
                controller: _searchController,
                labelText: 'Search Reports',
                obscureText: false,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _loadReports();
                },
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
