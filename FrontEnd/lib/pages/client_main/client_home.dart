import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/services/login_services.dart';
import 'package:login_page/components/my_client_list.dart';
import 'package:login_page/components/mytextfield.dart';
import 'package:login_page/services/client_service.dart';
import 'package:login_page/pages/client_main/client_product_view.dart';
import 'package:login_page/consts/consts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import 'package:login_page/components/my_error_dialog.dart';
import 'package:login_page/pages/client_main/qr_scanner_screen.dart';
import 'dart:async';

// Import our stub implementation
import 'package:login_page/platforms/web_stub.dart'
    if (dart.library.html) 'dart:html' as html;
import 'package:login_page/platforms/web_stub.dart'
    if (dart.library.js) 'dart:js' as js;

class ClientHome extends StatefulWidget {
  const ClientHome({super.key});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  List<dynamic> clientProductList = [];
  final ClientService _clientService = ClientService();
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = false; // Used for initial loading only
  bool isSearchLoading = false; // Separate flag for search operations
  bool isProcessing = false;
  bool isSearching = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    getProducts(isInitialLoad: true);
    // Add listener to search controller for real-time search
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Remove listener when disposing
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Debounce mechanism for search - to avoid too many API calls while typing
  Timer? _debounceTimer;

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  // Method to process the QR code from an uploaded image - Web only
  Future<void> processQrCodeFromImage(dynamic file) async {
    if (!kIsWeb) return; // Skip on non-web platforms

    setState(() {
      isProcessing = true;
    });

    try {
      final reader = html.FileReader();
      reader.readAsDataUrl(file);

      await for (final _ in reader.onLoad.take(1)) {
        // Load image into an HTML Image element
        final image = html.ImageElement();
        image.src = reader.result as String;

        await for (final _ in image.onLoad.take(1)) {
          // Create a canvas to draw the image
          final canvas = html.CanvasElement(
            width: image.width,
            height: image.height,
          );
          final ctx = canvas.context2D;
          ctx.drawImage(image, 0, 0);

          // Get image data for processing
          final imageData =
              ctx.getImageData(0, 0, canvas.width!, canvas.height!);

          // Call jsQR to decode the QR code
          final result = js.context.callMethod('jsQR', [
            imageData.data,
            imageData.width,
            imageData.height,
            {'inversionAttempts': 'dontInvert'},
          ]);

          if (result == null) {
            _showErrorDialog(
              'No QR Code Found',
              'No QR code could be detected in the image. Please try with a different image.',
            );
            return;
          }

          // Parse the QR code data
          try {
            final qrData = result['data'];
            final qrInfo = _parseQRData(qrData);

            if (!qrInfo.containsKey('productID') ||
                !qrInfo.containsKey('sku')) {
              _handleQRResult(QRScanResult.invalid);
              return;
            }

            // Process the QR code with the backend service
            String? token = await LoginServices(Dio()).getToken();
            final response = await _clientService.validateQRCode(
              productID: qrInfo['productID'],
              sku: qrInfo['sku'],
              token: token,
            );

            if (response.data == "This user already scanned this unit before") {
              _handleQRResult(QRScanResult.sucessButScanned);
              return;
            }

            if (response.data ==
                "Counterfeit, another user scanned this unit before") {
              _handleQRResult(QRScanResult.alreadyScanned);
              return;
            }

            // Check for the new counterfeit case where the product doesn't exist in DB
            if (response.data ==
                "Counterfeit, Product doesn't have this unit in the DB") {
              _handleQRResult(QRScanResult.counterfeitNotInDB);
              return;
            }

            if (response.statusCode == 200) {
              _handleQRResult(QRScanResult.success);
              // Refresh the product list
              await getProducts();
            } else {
              _handleQRResult(QRScanResult.error);
            }
          } catch (e) {
            _handleQRResult(QRScanResult.error);
          }
        }
      }
    } catch (e) {
      _showErrorDialog(
        'Error Reading File',
        'An error occurred while reading the file: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  // Handle different QR scan results consistently with mobile version
  void _handleQRResult(QRScanResult result) {
    switch (result) {
      case QRScanResult.success:
        _showSuccessSnackBar("QR code validated successfully!");
        break;
      case QRScanResult.sucessButScanned:
        _showSuccessSnackBar("You had already scanned this product!");
        break;
      case QRScanResult.alreadyScanned:
        _showErrorDialog(
          'Product already scanned before',
          'You can try again or submit a report with the product SKU for the system to check it manually',
          showTryAgain: true,
          showSubmit: true,
        );
        break;
      case QRScanResult.counterfeitNotInDB:
        _showErrorDialog(
          'Counterfeit Product Detected',
          'This product appears to be counterfeit as the unit does not exist in our database. Please submit a report to help us investigate further.',
          showTryAgain: true,
          showSubmit: true,
        );
        break;
      case QRScanResult.invalid:
        _showErrorDialog(
          'Invalid QR Code',
          'The QR code format is not recognized. Please scan a valid GenuineMark QR code.',
          showTryAgain: true,
          showSubmit: true,
        );
        break;
      case QRScanResult.error:
        _showErrorDialog(
          'Error Processing QR Code',
          'An error occurred while processing the QR code. Please try again.',
        );
        break;
    }
  }

  // Parse QR code data (similar to qr_scanner_screen.dart)
  Map<String, dynamic> _parseQRData(String qrData) {
    try {
      return jsonDecode(qrData);
    } catch (e) {
      print("Error parsing QR data: $e");
      return {};
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorDialog(String title, String message,
      {bool showTryAgain = false, bool showSubmit = false}) {
    showDialog(
      context: context,
      builder: (context) {
        if (showTryAgain || showSubmit) {
          return ErrorDialog(
            title: title,
            message: message,
            onTryAgain: showTryAgain
                ? () {
                    if (kIsWeb) {
                      // For web, just close the dialog and let user try again with a new image
                      _pickAndProcessImage();
                    } else {
                      // For mobile, navigate to QR scanner screen
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QRScannerScreen(),
                        ),
                      );
                    }
                  }
                : () {},
            onSubmit: showSubmit
                ? () {
                    Navigator.pushNamed(context, 'clientSubmitReport');
                  }
                : () {},
          );
        } else {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }
      },
    );
  }

  // Web-only methods for file picking and drag-drop

  // Method to pick an image and process it - Web only
  Future<void> _pickAndProcessImage() async {
    if (!kIsWeb) return; // Skip on non-web platforms

    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    await for (final _ in uploadInput.onChange.take(1)) {
      if (uploadInput.files!.isNotEmpty) {
        final file = uploadInput.files![0];
        await processQrCodeFromImage(file);
      }
    }
  }

  // Method to handle drag and drop - Web only
  void _handleDragDrop(html.Element dropZone) {
    if (!kIsWeb) return; // Skip on non-web platforms

    // Prevent default behavior for drag events
    for (final eventType in ['dragenter', 'dragover', 'dragleave', 'drop']) {
      dropZone.addEventListener(eventType, (event) {
        event.preventDefault();
        event.stopPropagation();
      });
    }

    // Handle drop event
    dropZone.addEventListener('drop', (event) {
      final mouseEvent = event as html.MouseEvent;
      final dataTransfer = mouseEvent.dataTransfer;

      if (dataTransfer != null && dataTransfer.files!.isNotEmpty) {
        final file = dataTransfer.files![0];
        processQrCodeFromImage(file);
      }
    });
  }

  // Register the drop zone once it's available in the DOM - Web only
  void _registerDropZone(String elementId) {
    if (!kIsWeb) return; // Skip on non-web platforms

    html.Element? element = html.document.getElementById(elementId);
    if (element != null) {
      _handleDragDrop(element);
    } else {
      // If the element is not immediately available, try again after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        html.Element? element = html.document.getElementById(elementId);
        if (element != null) {
          _handleDragDrop(element);
        }
      });
    }
  }

  // Web-only UI for file upload
  Widget _buildFileUploadArea() {
    if (!kIsWeb)
      return const SizedBox.shrink(); // Return empty widget for mobile

    // Create a unique ID for the drop zone
    final dropZoneId = 'drop-zone-${DateTime.now().millisecondsSinceEpoch}';

    // Register the drop zone after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerDropZone(dropZoneId);
    });

    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            Row(
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Upload QR Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Please upload a photo of the QR code',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 16),
            // Upload area with dotted border
            DottedBorder(
              color: Colors.grey.withOpacity(0.5),
              strokeWidth: 1.5,
              dashPattern: const [9, 5],
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              padding: const EdgeInsets.all(24),
              child: Center(
                // Assign the ID to the drop zone
                child: Builder(
                  builder: (context) {
                    // Create the div element
                    if (kIsWeb) {
                      final element = html.DivElement()
                        ..id = dropZoneId
                        ..style.width = '100%'
                        ..style.height = '100%';

                      // Register the view factory using the html API directly
                      html.document.body!.children.add(element);
                    }

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          // This is the actual drop zone - we'll use a placeholder here
                          // and manipulate the actual HTML element via DOM
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isProcessing)
                              const CircularProgressIndicator()
                            else
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            const SizedBox(height: 16),
                            Text(
                              'Choose a file or drag & drop it here',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'JPEG, PNG formats, up to 5MB',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: isProcessing
                                  ? null
                                  : () {
                                      _pickAndProcessImage();
                                    },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                side: const BorderSide(
                                    color: Colors.grey, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Browse File',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 109, 109, 109),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getProducts(
      {String? searchTerm, bool isInitialLoad = false}) async {
    // Only show full screen loader for initial load
    if (isInitialLoad) {
      setState(() {
        isLoading = true;
      });
    } else if (searchTerm != null) {
      // Show subtle search loading indicator
      setState(() {
        isSearchLoading = true;
      });
    }

    try {
      String? token = await LoginServices(Dio()).getToken();
      print("Token: $token");
      final products = await _clientService.getClientProducts(
        token: token,
        searchTerm: searchTerm,
      );

      if (mounted) {
        setState(() {
          clientProductList = products;
          isSearchLoading = false;
          isLoading = false;
        });
      }

      print(
          "Client Product List: ${clientProductList.map((p) => p.name).join(', ')}");
    } catch (e) {
      print("Error in getProducts: $e");
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
    getProducts(searchTerm: query);
  }

  // Method to clear search
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = "";
      isSearching = false;
    });
    getProducts();
  }

  // Add this method to build the product list widgets
  List<Widget> buildClientProductWidgets() {
    if (clientProductList.isEmpty) {
      // Show message when no products are found with the search term
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
                  'No products found matching "$searchQuery"',
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
      // Show message when no products have been scanned yet
      return [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No products scanned yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan a product QR code to get started',
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

    // Return products with a staggered animation effect
    return List.generate(clientProductList.length, (index) {
      final product = clientProductList[index];
      // Create a slight staggered effect
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 4),
        child: ClientList(
          onPressed: () {
            print("Tapped on product: ${product.name}");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  print(
                      "Creating CllientProductVeiw with product: ${product.name}");
                  return ClientProductView(product: product);
                },
              ),
            );
          },
          // Use the product image if available, otherwise use the default
          image: product.image ?? 'lib/images/stock.jpg',
          name: product.name,
          // Format the price as "EGP X,XXX"
          firstText:
              'EGP ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
          // Format the duration as "X Months"
          secondText: '${product.durationLeft} Months',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (kIsWeb && isDesktop(context)) _buildFileUploadArea(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Scanned Products",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Stack(
                children: [
                  MyTextfield(
                    controller: _searchController,
                    labelText: "Search",
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
                  key: ValueKey<String>(
                      searchQuery), // Use searchQuery as key to trigger animation
                  children: buildClientProductWidgets(),
                ),
              ),
            ],
          );
  }
}
