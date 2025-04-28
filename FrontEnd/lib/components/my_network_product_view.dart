import 'package:flutter/material.dart';
import 'package:login_page/consts/consts.dart';

class MyNetworkProductview extends StatelessWidget {
  final String? name;
  final String? image;
  final int? scans;
  final String? scanLabel;
  const MyNetworkProductview({
    super.key, 
    this.image, 
    this.name, 
    this.scans,
    this.scanLabel = "Scans",
  });

  String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null) return '';
    if (imageUrl.startsWith('http')) {
      // Replace localhost with baseUrl's host
      final uri = Uri.parse(baseUrl);
      return imageUrl.replaceFirst('localhost', uri.host);
    }
    // If it's a relative path
    return baseUrl.replaceAll('/api', '') + imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 400,
      decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFC4C4C4),
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              name!,
              style: const TextStyle(
                  color: MYmaincolor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Image.network(
              getFullImageUrl(image),
              width: 200,
              height: 110,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Center(
            child: Text(
              "${scans ?? 0} ${scanLabel ?? 'Scans'}",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
} 