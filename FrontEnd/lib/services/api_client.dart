import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:login_page/models/utils.dart';
import 'package:login_page/consts/consts.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl, // becareful you are changing this
      connectTimeout:
          const Duration(seconds: 10), // Longer timeout for file uploads
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  void setAuthToken(String? token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Helper method to switch to multipart/form-data for file uploads
  void setMultipartFormData() {
    dio.options.headers['Content-Type'] = 'multipart/form-data';
  }

  // Helper to switch back to JSON
  void setJsonContentType() {
    dio.options.headers['Content-Type'] = 'application/json';
  }

  // Method to handle file uploads with appropriate content type for both web and mobile
  Future<Response> uploadFile(String path, dynamic fileData, String fieldName,
      {Map<String, dynamic>? extraData,
      // scan uses Patch request so:
      String method =
          'POST' // Add method parameter with POST default change later
      }) async {
    try {
      FormData formData;

      if (fileData is ImageData) {
        if (kIsWeb) {
          // For web platform, use bytes
          formData = FormData.fromMap({
            fieldName: MultipartFile.fromBytes(
              fileData.bytes!,
              filename: 'image.jpg', // Default filename for web
            ),
            if (extraData != null) ...extraData,
          });
        } else {
          // For mobile platform, use file path from ImageData
          formData = FormData.fromMap({
            fieldName: await MultipartFile.fromFile(
              fileData.file!.path,
              filename: fileData.file!.path.split('/').last,
            ),
            if (extraData != null) ...extraData,
          });
        }
      } else if (fileData is File) {
        // Backward compatibility for old File-based uploads
        formData = FormData.fromMap({
          fieldName: await MultipartFile.fromFile(
            fileData.path,
            filename: fileData.path.split('/').last,
          ),
          if (extraData != null) ...extraData,
        });
      } else {
        throw ArgumentError('fileData must be either ImageData or File');
      }

      setMultipartFormData();

      // Modified request handling
      final response = await dio.request(
        path,
        data: formData,
        options: Options(method: method),
      );

      setJsonContentType();
      return response;
    } catch (e) {
      setJsonContentType();
      rethrow;
    }
  }
}
