import 'package:flutter/material.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/ImageCarousel.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class FullscreenCarouselDialog extends StatelessWidget {
  final List<String> images;
  final Color color;
  FullscreenCarouselDialog({
    @required this.images,
    this.color = Constants.primaryColor,
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
        ),
      ),
    );
  }
}