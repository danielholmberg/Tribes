import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tribes/core/tribe/widgets/custom_image.dart';

enum IndicatorPosition {
  bottomRight,
  topRight,
}

class ImageCarousel extends StatefulWidget {
  final Key key;
  final List<String> images;
  final Color color;
  final bool small;
  final int initialIndex;
  final Function onPageChange;
  final IndicatorPosition indicatorPosition;
  ImageCarousel({
    this.key,
    @required this.images,
    this.color = Colors.white,
    this.small = false,
    this.initialIndex = 0,
    this.onPageChange,
    this.indicatorPosition = IndicatorPosition.topRight,
  });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel>
    with SingleTickerProviderStateMixin {
  int _current;

  @override
  void initState() {
    _current = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool showIndicator = widget.images.length > 1;

    _buildImageIndicator() {
      return Container(
          padding: EdgeInsets.symmetric(
              vertical: widget.small ? 2.0 : 4.0,
              horizontal: widget.small ? 4.0 : 6.0),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.6),
            borderRadius: BorderRadius.circular(1000),
          ),
          child: Row(
            children: <Widget>[
              Text(
                '${_current + 1} of ${widget.images.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.small ? 8 : 10,
                  fontFamily: 'TribesRounded',
                ),
              ),
            ],
          ));
    }

    return Stack(
      key: widget.key,
      alignment: Alignment.center,
      children: <Widget>[
        // Images
        Container(
          width: MediaQuery.of(context).size.width,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              initialPage: widget.initialIndex,
              viewportFraction: 1.0,
              reverse: false,
              autoPlay: false,
              enableInfiniteScroll: false,
              enlargeCenterPage: false,
              aspectRatio: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
                if (widget.onPageChange != null) widget.onPageChange(index);
              },
            ),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return CustomImage(
                imageURL: widget.images[index],
                color: widget.color,
                small: widget.small,
                fullscreen: false,
              );
            },
          ),
        ),

        widget.indicatorPosition == IndicatorPosition.topRight
            ? Positioned(
                top: widget.small ? 4.0 : 8.0,
                right: widget.small ? 4.0 : 8.0,
                child: Visibility(
                  visible: showIndicator,
                  child: _buildImageIndicator(),
                ),
              )
            : Positioned(
                bottom: widget.small ? 4.0 : 8.0,
                right: widget.small ? 4.0 : 8.0,
                child: Visibility(
                  visible: showIndicator,
                  child: _buildImageIndicator(),
                ),
              )
      ],
    );
  }
}
