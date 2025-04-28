import 'package:flutter/material.dart';
import 'package:login_page/models/unit_model.dart';
import 'package:login_page/services/get_units.dart';
import 'dart:async';

class AdminViewProduct extends StatefulWidget {
  final String token;
  final String productId;

  const AdminViewProduct({
    super.key,
    required this.token,
    required this.productId,
  });

  @override
  State<AdminViewProduct> createState() => _AdminViewProductState();
}

class _AdminViewProductState extends State<AdminViewProduct> {
  final GetUnits _getUnits = GetUnits();
  List<UnitModel> _units = [];
  List<UnitModel> _filteredUnits = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnits() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final units = await _getUnits.getAdmins(
        widget.token,
        widget.productId,
      );

      setState(() {
        _units = units;
        _filteredUnits = units;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load units: $e';
        _isLoading = false;
      });
    }
  }

  void _filterUnits(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUnits = _units;
      });
      return;
    }

    setState(() {
      _filteredUnits = _units.where((unit) {
        final sku = unit.sku?.toLowerCase() ?? '';
        final status = unit.status?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return sku.contains(searchQuery) || status.contains(searchQuery);
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _filterUnits(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Units'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by SKU or status...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterUnits('');
                  },
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _filteredUnits.isEmpty
                        ? const Center(child: Text('No units found'))
                        : ListView.builder(
                            itemCount: _filteredUnits.length,
                            itemBuilder: (context, index) {
                              final unit = _filteredUnits[index];
                              return ListTile(
                                title: Text(unit.sku ?? 'No SKU'),
                                subtitle:
                                    Text('Status: ${unit.status ?? 'Unknown'}'),
                                // Add more unit details as needed
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
