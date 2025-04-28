import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/services/client_service.dart';
import 'package:login_page/services/login_services.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:convert';

enum QRScanResult {
  success,
  sucessButScanned,
  alreadyScanned,
  counterfeitNotInDB,
  invalid,
  error,
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  QRViewController? qrController;
  bool isProcessing = false;
  final ClientService _clientService = ClientService();

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await qrController?.pauseCamera();
    }
    await qrController?.resumeCamera();
  }

  /// Process QR code data and send to backend
  Future<QRScanResult> _processQRData(String qrData) async {
    try {
      // Parse QR code data
      final qrInfo =
          _parseQRData(qrData); // it comes as string and i need it as map
      print(qrInfo);

      if (!qrInfo.containsKey('productID') || !qrInfo.containsKey('sku')) {
        print("Invalid QR format: Missing required fields");
        return QRScanResult.invalid;
      }

      String? token = await LoginServices(Dio()).getToken();

      // Send the extracted data to backend
      final response = await _clientService.validateQRCode(
        productID: qrInfo['productID'],
        sku: qrInfo['sku'],
        token: token,
      );

      print(response);

      if (response.data == "This user already scanned this unit before") {
        return QRScanResult.sucessButScanned;
      }

      if (response.data ==
          "Counterfeit, another user scanned this unit before") {
        return QRScanResult.alreadyScanned;
      }

      // Check for the new counterfeit case where the product doesn't exist in DB
      if (response.data ==
          "Counterfeit, Product doesn't have this unit in the DB") {
        return QRScanResult.counterfeitNotInDB;
      }

      return response.statusCode == 200
          ? QRScanResult.success
          : QRScanResult.invalid;
    } catch (e) {
      print("Error processing QR data: $e");
      return QRScanResult.error;
    }
  }

  /// Parse QR code data to extract productID and sku
  Map<String, dynamic> _parseQRData(String qrData) {
    try {
      // Option 3: If QR contains custom format like "productID:123,sku:ABC123"
      Map<String, dynamic> resultCode = jsonDecode(qrData);

      return resultCode;
    } catch (e) {
      print("Error parsing QR data: $e");
      return {};
    }
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      qrController = controller;
    });

    // Listen for QR code scans
    controller.scannedDataStream.listen((scanData) async {
      if (isProcessing || scanData.code == null) return;

      setState(() {
        isProcessing = true;
      });

      // Pause camera
      await qrController?.pauseCamera();

      // Process the QR code data
      final result = await _processQRData(scanData.code!);

      // Return the result to the previous screen
      if (mounted) {
        Navigator.pop(context, result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: onQRViewCreated,
            overlay: QrScannerOverlayShape(
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
              borderWidth: 10,
              borderLength: 20,
              borderRadius: 5,
              borderColor: Colors.blueAccent,
            ),
            formatsAllowed: const [BarcodeFormat.qrcode],
            cameraFacing: CameraFacing.back,
          ),
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Processing QR Code...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
