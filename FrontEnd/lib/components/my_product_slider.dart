import 'package:flutter/material.dart';
import 'package:login_page/components/my_slider_item.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/recommendation_model.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MyProductSlider extends StatefulWidget {
  final List<RecommendationModel>? recommendations;
  final String? productId;
  final bool isLoading;

  const MyProductSlider({
    super.key,
    this.recommendations,
    this.productId,
    this.isLoading = false,
  });

  @override
  State<MyProductSlider> createState() => _MyProductSliderState();
}

class _MyProductSliderState extends State<MyProductSlider> {
  int _currentIndex = 0;
  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    bool desktop = isDesktop(context);

    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: MYmaincolor,
        ),
      );
    }

    if (widget.recommendations == null || widget.recommendations!.isEmpty) {
      return const Center(
        child: Text(
          "No recommendations available",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    final items = widget.recommendations!.map((product) {
      return MySliderItem(product: product);
    }).toList();

    return desktop ? _buildDesktopSlider(items) : _buildMobileSlider(items);
  }

  Widget _buildMobileSlider(List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CarouselSlider(
        items: items,
        options: CarouselOptions(
          height: 500,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          enlargeCenterPage: true,
          enableInfiniteScroll: items.length > 1,
          viewportFraction: 0.65,
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDesktopSlider(List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        height: 440,
        child: CarouselSlider(
          items: items,
          options: CarouselOptions(
            height: 410,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            enableInfiniteScroll: items.length > 1,
            viewportFraction: 0.4,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
