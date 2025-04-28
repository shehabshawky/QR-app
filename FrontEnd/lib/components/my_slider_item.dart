import 'package:flutter/material.dart';
import 'package:login_page/components/mybutton.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/recommendation_model.dart';
import 'package:login_page/pages/client_main/client_product_view.dart';

class MySliderItem extends StatelessWidget {
  final RecommendationModel? product;

  const MySliderItem({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    // Default values if no product is provided
    final name = product?.name ?? "Product Name";
    final price = product?.price ?? 0.0;
    final description = product?.description ?? "No description available";
    final imageUrl = product?.image;
    final bool desktop = isDesktop(context);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: desktop ? 350 : 370,
        ),
        child: Container(
          width: desktop ? 280 : 220,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 168, 167, 167),
              style: BorderStyle.solid,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: desktop ? 260 : 200,
                height: 120,
                margin: const EdgeInsets.all(12),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset("lib/images/image.png");
                        },
                        fit: BoxFit.contain,
                      )
                    : Image.asset("lib/images/image.png"),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "EGP ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          description,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w300),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        alignment: Alignment.center,
                        child: Mybutton(
                          buttonName: "View Details",
                          onPressed: () {
                            if (product != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClientProductView(
                                    product: product,
                                  ),
                                ),
                              );
                            }
                          },
                          buttonWidth: 150,
                          buttonHeight: 36,
                          buttonColor: MYmaincolor,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
