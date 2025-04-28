import 'package:flutter/material.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/pages/client_main/qr_scanner_screen.dart';
import 'client_home.dart';
import 'client_reports_screen.dart';
import 'temp_client_profile_screen.dart';
import 'package:login_page/components/my_error_dialog.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int currentIndex = 0;
  int? hoveredIndex;
  final List<Widget> screens = [
    const ClientHome(),
    const ClientReportsScreen(),
    const ClientProfile(),
  ];
  final keyrefresh = GlobalKey<RefreshIndicatorState>();
  final List<String> navstrings = ["Home", "Reports", "Profile"];

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<void> _scanQR() async {
    // Show a brief message to let the user know what's happening
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Position the QR code in the frame."),
        duration: Duration(seconds: 2),
      ),
    );

    final result = await Navigator.push<QRScanResult>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    // Handle the result
    if (result != null) {
      switch (result) {
        case QRScanResult.success:
          // Handle successful QR scan
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("QR code validated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.popAndPushNamed(context, 'clientHomeScreen');
          break;

        case QRScanResult.sucessButScanned:
          // Handle successful but already scanned QR scan
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You had already scanned this product!"),
              backgroundColor: Colors.blueGrey,
            ),
          );
          Navigator.popAndPushNamed(context, 'clientHomeScreen');
          break;

        case QRScanResult.alreadyScanned:
          // Handle already scanned
          showDialog(
            context: context,
            builder: (context) {
              return ErrorDialog(
                title: "Product already scanned before",
                message:
                    "You can try again or submit a report with the product SKU for the system to check it manually",
                onTryAgain: () {
                  _scanQR(); // Scan again
                },
                onSubmit: () {
                  Navigator.pushNamed(context, 'clientSubmitReport');
                },
              );
            },
          );
          break;

        case QRScanResult.invalid:
          // Invalid is a wrong QR format (not in the {productID, sku} format)
          showDialog(
            context: context,
            builder: (context) {
              return ErrorDialog(
                title: "Couldn't Recognize the QR code",
                message:
                    "You can try again or submit a report with the product SKU for the system to check it manually",
                onTryAgain: () {
                  _scanQR(); // Scan again
                },
                onSubmit: () {
                  Navigator.pushNamed(context, 'clientSubmitReport');
                },
              );
            },
          );
          break;

        case QRScanResult.counterfeitNotInDB:
          // Handle counterfeit product not in database
          showDialog(
            context: context,
            builder: (context) {
              return ErrorDialog(
                title: "Counterfeit Product Detected",
                message:
                    "This product appears to be counterfeit as the unit does not exist in our database. Please submit a report to help us investigate further.",
                onTryAgain: () {
                  _scanQR(); // Scan again
                },
                onSubmit: () {
                  Navigator.pushNamed(context, 'clientSubmitReport');
                },
              );
            },
          );
          break;

        case QRScanResult.error:
          // Show generic error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "An error occurred while processing the QR code. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isDesktop(context)
          ? Row(
              children: [
                // Desktop Navigation
                Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: Colors.black12,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Logo Space
                      const SizedBox(height: 60),
                      const Icon(
                        Icons.qr_code,
                        size: 60,
                        color: MYmaincolor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "GenuineMark",
                        style: TextStyle(
                          color: MYmaincolor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Navigation Items
                      ...List.generate(
                        navstrings.length,
                        (index) => MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => setState(() {
                            hoveredIndex = index;
                          }),
                          onExit: (_) => setState(() {
                            hoveredIndex = null;
                          }),
                          child: InkWell(
                            onTap: () => _onItemTapped(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              color: currentIndex == index
                                  ? MYmaincolor.withOpacity(0.1)
                                  : hoveredIndex == index
                                      ? MYmaincolor.withOpacity(
                                          0.05) // Hover text color
                                      : Colors.transparent,
                              child: Row(
                                children: [
                                  Icon(
                                    index == 0
                                        ? Icons.home_outlined
                                        : index == 1
                                            ? Icons.report_outlined
                                            : Icons.person_outline,
                                    color: currentIndex == index
                                        ? MYmaincolor
                                        : Colors.black,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    navstrings[index],
                                    style: TextStyle(
                                      color: currentIndex == index
                                          ? MYmaincolor
                                          : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Top App Bar
                      AppBar(
                        title: Text(
                          navstrings[currentIndex],
                          style: const TextStyle(
                            color: MYmaincolor,
                            fontSize: 30,
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        centerTitle: false,
                        automaticallyImplyLeading: false,
                      ),
                      // Main Content
                      Expanded(
                        child: Center(
                          child: ListView(children: <Widget>[
                            Container(
                              constraints: const BoxConstraints(maxWidth: 1200),
                              padding: const EdgeInsets.all(24),
                              child: screens[currentIndex],
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: SizedBox(
                width: 850,
                child: ListView(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                      child: screens[currentIndex],
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: !isDesktop(context)
          ? FloatingActionButton(
              onPressed: _scanQR,
              backgroundColor: MYmaincolor,
              tooltip: 'Scan QR Code',
              child: const Icon(
                Icons.qr_code_scanner_outlined,
                color: Colors.white,
              ),
            )
          : null,
      bottomNavigationBar: !isDesktop(context)
          ? BottomNavigationBar(
              backgroundColor: const Color.fromARGB(224, 255, 255, 255),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.report_outlined),
                  label: 'Reports',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
              currentIndex: currentIndex,
              onTap: _onItemTapped,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: MYmaincolor,
              unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
              iconSize: 32,
            )
          : null,
    );
  }
}
