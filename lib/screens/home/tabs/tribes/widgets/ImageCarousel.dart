import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/CustomImage.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final Color color;
  final bool small;
  final bool fullscreen;
  ImageCarousel({
    @required this.images,
    this.color = Constants.primaryColor,
    this.small = false,
    this.fullscreen = false,
  });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final mainAxisSize = widget.fullscreen ? MainAxisSize.max : MainAxisSize.min;

    buildCarousel() {
      return widget.fullscreen 
      ? Expanded(
        child: CarouselSlider.builder(
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return CustomImage(
              imageURL: widget.images[index],
              color: widget.color,
              small: widget.small,
              fullscreen: widget.fullscreen,
            );
          },
          viewportFraction: 1.0,
          reverse: false,
          autoPlay: false,
          enableInfiniteScroll: false,
          enlargeCenterPage: false,
          aspectRatio: 0.6,
          onPageChanged: (index) {
            setState(() {
              _current = index;
            });
          },
        ),
      )
      : Container(
        child: CarouselSlider.builder(
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return CustomImage(
              imageURL: widget.images[index],
              color: widget.color,
              small: widget.small,
              fullscreen: widget.fullscreen,
            );
          },
          viewportFraction: 1.0,
          reverse: false,
          autoPlay: false,
          enableInfiniteScroll: false,
          enlargeCenterPage: false,
          aspectRatio: 1.0,
          onPageChanged: (index) {
            setState(() {
              _current = index;
            });
          },
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: mainAxisSize,
      children: <Widget>[
        buildCarousel(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) {
            return Container(
              width: widget.small ? 4.0 : 8.0,
              height: widget.small ? 4.0 : 8.0,
              margin: EdgeInsets.symmetric(vertical: widget.small ? 3.0 : 6.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == index ? widget.color : widget.color.withOpacity(0.2),
              ),
            );
          }),
        )
      ],
    );
  }
}