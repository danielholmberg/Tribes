import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/screens/base/tribes/widgets/CustomImage.dart';
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';

enum IndicatorPosition {
  bottomRight,
  topRight,
}

class ImageCarousel extends StatefulWidget {
  final Key key;
  final List<String> images;
  final Color color;
  final bool small;
  final bool fullscreen;
  final int initialIndex;
  final Function onPageChange;
  final IndicatorPosition indicatorPosition;
  ImageCarousel({
    this.key,
    @required this.images,
    this.color = Colors.white,
    this.small = false,
    this.fullscreen = false,
    this.initialIndex = 0,
    this.onPageChange,
    this.indicatorPosition = IndicatorPosition.topRight,
  });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {

  int _current;

  @override
  void initState() {
    _current = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool showIndicator = widget.images.length > 1;
    
    _buildFullscreenCarousel() {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          CarouselSlider.builder(
            initialPage: widget.initialIndex,
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
              if(widget.onPageChange != null) widget.onPageChange(index);
            },
          ),
        ],
      );
    }

    _buildNormalCarousel() {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: CarouselSlider.builder(
          initialPage: widget.initialIndex,
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
            if(widget.onPageChange != null) widget.onPageChange(index);
          },
        ),
      );
    }

    _buildDismissButton() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget> [
            IconButton(
              icon: CustomAwesomeIcon(
                icon: Platform.isIOS ? FontAwesomeIcons.chevronLeft : FontAwesomeIcons.arrowLeft,
                color: widget.color,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 4.0,
                    color: Colors.black,
                  ),
                ],
              ),
              splashColor: Colors.transparent,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }

    _buildFullscreenIndicator() {
      return Container(
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20)
        ),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            margin: EdgeInsets.symmetric(horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index ? widget.color : widget.color.withOpacity(0.2),
            ),
            child: Text(
              '${index+1}',
              style: TextStyle(
                color: _current == index ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontFamily: 'TribesRounded',
              ),
            ),
          )),
        ),
      );
    }

    _buildNormalIndicator() {
      return Container(
        padding: EdgeInsets.symmetric(vertical: widget.small ? 2.0 : 4.0, horizontal: widget.small ? 4.0 : 6.0),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.6),
          borderRadius: BorderRadius.circular(1000),
        ),
        child: Row(
          children: <Widget>[
            Text(
              '${_current+1} of ${widget.images.length}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: widget.small ? 8 : 10,
                fontFamily: 'TribesRounded',
              ),
            ),
          ],
        )
      );
    }

    return Stack(
      key: widget.key,
      alignment: Alignment.center,
      children: <Widget>[
        widget.fullscreen ? _buildFullscreenCarousel() : _buildNormalCarousel(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Visibility(visible: widget.fullscreen, child: _buildDismissButton()),
        ),
        widget.fullscreen ? Positioned(
          bottom: 8.0,
          child: Visibility(visible: showIndicator, child: _buildFullscreenIndicator()),
        ) : (
          widget.indicatorPosition == IndicatorPosition.topRight ? 
          Positioned(
            top: widget.small ? 4.0 : 8.0,
            right: widget.small ? 4.0 : 8.0,
            child: Visibility(
              visible: showIndicator, 
              child: _buildNormalIndicator(),
            ),
          ) : Positioned(
            bottom: widget.small ? 4.0 : 8.0,
            right: widget.small ? 4.0: 8.0,
            child: Visibility(
              visible: showIndicator, 
              child: _buildNormalIndicator(),
            ),
          )
        )
      ],
    );
  }
}