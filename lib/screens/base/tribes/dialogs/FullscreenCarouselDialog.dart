import 'package:flutter/material.dart';
import 'package:tribes/screens/base/tribes/widgets/ImageCarousel.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class FullscreenCarouselDialog extends StatelessWidget {
  final List<String> images;
  final Color color;
  final int initialIndex;
  final Function onPageChange;
  FullscreenCarouselDialog({
    @required this.images,
    this.color = Constants.primaryColor,
    this.initialIndex = 0,
    this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        color: Colors.black87,
        child: ImageCarousel(
          images: images,
          color: color,
          fullscreen: true,
          initialIndex: initialIndex,
          onPageChange: onPageChange,
        ),
      ),
    );
  }
}