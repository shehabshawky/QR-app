import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/components/my_client_list.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/services/login_services.dart';
import 'package:login_page/models/client_report_model.dart';
import 'package:login_page/services/client_reports_service.dart';

class ClientReportsScreen extends StatefulWidget {
  const ClientReportsScreen({super.key});

  @override
  _ClientReportsScreenState createState() => _ClientReportsScreenState();
}

class _ClientReportsScreenState extends State<ClientReportsScreen> {
  List<ClientReportModel> clientReports = [];
  final ClientReportsService _reportService = ClientReportsService();
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = false;
  bool isSearchLoading = false;
  bool isSearching = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    getReports(isInitialLoad: true);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Debounce mechanism for search
  int _debounceTimer = 0;

  void _onSearchChanged() {
    final timer = DateTime.now().millisecondsSinceEpoch;
    _debounceTimer = timer;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_debounceTimer == timer) {
        _performSearch();
      }
    });
  }

  Future<void> getReports({
    String? searchTerm,
    bool isInitialLoad = false,
  }) async {
    if (isInitialLoad) {
      setState(() {
        isLoading = true;
      });
    } else if (searchTerm != null) {
      setState(() {
        isSearchLoading = true;
      });
    }

    try {
      String? token = await LoginServices(Dio()).getToken();
      final reports = await _reportService.getClientReports(
        token: token,
        searchTerm: searchTerm,
      );

      if (mounted) {
        setState(() {
          clientReports = reports;
          isSearchLoading = false;
          isLoading = false;
        });
      }

      print(
          "Client Reports: ${clientReports.map((r) => r.productName).join(', ')}");
    } catch (e) {
      print("Error in getReports: $e");
      if (mounted) {
        setState(() {
          isSearchLoading = false;
          isLoading = false;
        });
      }
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    setState(() {
      searchQuery = query;
      isSearching = true;
    });
    getReports(searchTerm: query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = "";
      isSearching = false;
    });
    getReports();
  }

  // Get appropriate color for report status
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'counterfeit':
        return Colors.red;

      case 'original':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Show the status explanation dialog
  void _showVerdictDialog(ClientReportModel report) {
    String title = "Verdict";
    String message = "";

    switch (report.status.toLowerCase()) {
      case 'counterfeit':
        message =
            "Can't be found in company's Database Or another user scanned it before.\n\n"
            "This means either:\n"
            "• The product doesn't exist in our database\n"
            "• Another user has already scanned this product, which may indicate a duplicated QR code\n"
            "• The QR code may have been tampered with";
        break;
      case 'original':
        message =
            "Product SKU found in database. The Report was a QR scan Error.\n\n"
            "This means:\n"
            "• The product was verified as genuine\n"
            "• The QR code matches our database records\n"
            "• Any previous scanning issues were likely temporary or due to connection problems";
        break;
      default:
        message = "Status: ${report.status}\n\n"
            "This report is still being processed or has an unrecognized status.";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Build widgets for report list
  List<Widget> buildReportWidgets() {
    if (clientReports.isEmpty) {
      // Show message when no reports are found with the search term
      if (isSearching && searchQuery.isNotEmpty) {
        return [
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No reports found matching "$searchQuery"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ];
      }
      // Show message when no reports exist yet
      return [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.report_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No reports submitted yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'When you submit reports about products, they will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ];
    }

    // Return reports with a staggered animation effect
    return List.generate(clientReports.length, (index) {
      final report = clientReports[index];
      // Create a slight staggered effect
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 4),
        child: ClientList(
          onPressed: () {
            // Show verdict dialog when report is clicked
            _showVerdictDialog(report);
          },
          image: 'lib/images/stock.jpg', // Default image for reports
          name: report.productName,
          // First text is the SKU
          firstText: 'SKU: ${report.sku}',
          // Second text is the status
          secondText: report.status.toUpperCase(),
          // Set color for status
          secondTextColor: getStatusColor(report.status),
          // Custom right icon for info
          customRightIcon: const Icon(
            Icons.info_outline,
            size: 26,
            color: Colors.grey,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator(color: MYmaincolor))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Reports",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Stack(
                children: [
                  MyTextfield(
                    controller: _searchController,
                    labelText: "Search Reports",
                    suffixIcon: searchQuery.isEmpty
                        ? IconButton(
                            onPressed: _performSearch,
                            icon: const Icon(Icons.search),
                            color: Colors.black,
                          )
                        : IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.clear),
                            color: Colors.black,
                          ),
                    width: 300,
                  ),
                  if (isSearchLoading)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                ],
              ),
              if (isSearching && searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Showing results for "$searchQuery"',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Use AnimatedSwitcher for smooth transitions when list content changes
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: Column(
                  key: ValueKey<String>(searchQuery),
                  children: buildReportWidgets(),
                ),
              ),
            ],
          );
  }
}
