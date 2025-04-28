import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';
import 'package:login_page/services/get_admins_service.dart';
import 'package:login_page/services/login_services.dart';
import 'package:login_page/models/adminslistmodel.dart';
import 'package:login_page/services/super_admin_analytics_service.dart';
import 'package:login_page/services/super_admin_logs_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SuperAdminLogs extends StatefulWidget {
  const SuperAdminLogs({super.key});

  @override
  State<SuperAdminLogs> createState() => _SuperAdminLogsState();
}

class _SuperAdminLogsState extends State<SuperAdminLogs> {
  bool show_calendar = false;
  DateTime? startDate;
  DateTime? endDate;
  bool isSelectingStartDate = true;
  String? _selectedCompany;
  List<Adminslistmodel> companiesList = [];
  bool isLoading = true;
  Map<String, dynamic>? overallAnalytics;
  List<dynamic> logs = [];
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Adminslistmodel? get selectedCompanyData {
    if (_selectedCompany == null || _selectedCompany == 'all') return null;
    return companiesList.firstWhere((company) => company.id == _selectedCompany);
  }

  @override
  void initState() {
    super.initState();
    fetchCompanies();
    fetchOverallAnalytics();
    fetchLogs();
  }

  Future<void> fetchCompanies() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await LoginServices(Dio()).getToken();
      companiesList = await GetAdminsService().getAdmins(token);
      
      if (companiesList.isNotEmpty) {
        setState(() {
          _selectedCompany = 'all';
          isLoading = false;
        });
      } else {
        print('No companies returned from API');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching companies: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchOverallAnalytics() async {
    try {
      String? token = await LoginServices(Dio()).getToken();
      final analytics = await SuperAdminAnalyticsService().getSuperAdminAnalytics(token);
      setState(() {
        overallAnalytics = analytics;
      });
    } catch (e) {
      print('Error fetching overall analytics: $e');
    }
  }

  Future<void> fetchLogs() async {
    try {
      String? token = await LoginServices(Dio()).getToken();
      
      // Get the company name from the selected company data
      String? adminName;
      if (_selectedCompany != null && _selectedCompany != 'all') {
        adminName = companiesList.firstWhere((company) => company.id == _selectedCompany).name;
      }

      // Format dates in YYYY-MM-DD format
      String? formattedStartDate = startDate?.toIso8601String().split('T')[0];
      String? formattedEndDate = endDate?.toIso8601String().split('T')[0];

      final response = await SuperAdminLogsService().getSuperAdminLogs(
        token,
        adminName: adminName,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
        action: searchController.text.isEmpty ? null : searchController.text,
      );
      
      setState(() {
        logs = response['logs'];
      });
    } catch (e) {
      print('Error fetching logs: $e');
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      if (isSelectingStartDate) {
        startDate = day;
        isSelectingStartDate = false;
      } else {
        if (day.isBefore(startDate!)) {
          endDate = startDate;
          startDate = day;
        } else {
          endDate = day;
        }
        isSelectingStartDate = true;
        show_calendar = false;
        fetchLogs(); // Fetch logs when date range changes
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
        focusedDay: isSelectingStartDate ? 
          (startDate ?? DateTime.now()) : 
          (endDate ?? DateTime.now()),
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

  Widget _buildDetailRow(String label, String value, bool isFirst) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: isFirst ? BorderSide.none : BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: value.contains("@") ? const Color(0xFF2E7D32) : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOverallStats() {
    if (overallAnalytics == null) return Container();
    
    return Container(
      margin: const EdgeInsets.only(top: 20),
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
            "Overall Statistics",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildDetailRow("Total Companies:", "${overallAnalytics!['totalAdmins']} Companies", false),
                _buildDetailRow("Total Products:", "${overallAnalytics!['totalProducts']} Products", false),
                _buildDetailRow("Total Units:", "${overallAnalytics!['totalUnits']} Units", false),
                _buildDetailRow("Total Scans:", "${overallAnalytics!['totalScans']} Scans", true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCompanyStats() {
    if (_selectedCompany == null || _selectedCompany == 'all' || selectedCompanyData == null) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
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
          // Company Logo and Name
          Row(
            children: [
              if (selectedCompanyData!.image != null)
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(selectedCompanyData!.image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Text(
                selectedCompanyData!.name,
                style: const TextStyle(
                  fontSize: 40,
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Company Details in table-like format
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildDetailRow("Email:", selectedCompanyData!.email, true),
                _buildDetailRow("Total Products:", "${selectedCompanyData!.productsCount} Products", false),
                _buildDetailRow("Total Units:", "${selectedCompanyData!.qRCodesCount} Units", false),
                _buildDetailRow("Scanned Units:", "${selectedCompanyData!.scannedUnitsCount} Units", false),
                _buildDetailRow("Counterfeit Reports:", "${selectedCompanyData!.counterfeitReportsCount} Reports", false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLogsTable() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Action',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  fetchLogs();
                });
              },
            ),
          ),
          Container(
            width: double.infinity,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.grey[200],
                cardColor: Colors.white,
              ),
              child: DataTable(
                headingRowHeight: 56,
                dataRowHeight: 56,
                horizontalMargin: 24,
                columnSpacing: 24,
                border: TableBorder(
                  horizontalInside: BorderSide(color: Colors.grey[200]!),
                ),
                columns: [
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Company',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Time',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Action',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
                rows: logs.map<DataRow>((log) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          log['adminName'] ?? '',
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          DateFormat('dd/MM/yyyy \'at\' h:mm a').format(DateTime.parse(log['date'])),
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataCell(
                        Expanded(
                          child: Text(
                            log['action'] ?? '',
                            style: const TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${logs.length} selected',
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        // TODO: Implement previous page
                      },
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement next page
                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building with companies: ${companiesList.map((c) => c.name).toList()}'); // Debug log
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Stats (always visible)
                  buildOverallStats(),

                  // Filters section
                  Container(
                    margin: const EdgeInsets.only(top: 20),
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
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    show_calendar = true;
                                    isSelectingStartDate = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                          "Start: ${startDate?.toString().split(" ")[0] ?? 'Select Date'}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    show_calendar = true;
                                    isSelectingStartDate = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                          "End: ${endDate?.toString().split(" ")[0] ?? 'Select Date'}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Company selection
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          hint: const Text('Select Company'),
                          decoration: InputDecoration(
                            labelText: 'Company',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          value: _selectedCompany,
                          items: <DropdownMenuItem<String>>[
                            const DropdownMenuItem<String>(
                              value: 'all',
                              child: Text('All Companies'),
                            ),
                            ...companiesList.map((company) => DropdownMenuItem<String>(
                              value: company.id,
                              child: Text(company.name),
                            )).toList(),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCompany = newValue;
                            });
                            fetchLogs();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Calendar widget
                  buildCalendar(),

                  // Company specific stats (only when a company is selected)
                  buildCompanyStats(),

                  // Logs Table
                  buildLogsTable(),
                ],
              ),
            ),
          );
  }
} 