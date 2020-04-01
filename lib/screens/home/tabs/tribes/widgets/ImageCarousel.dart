import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/CustomImage.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';

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
    
    buildFullscreenCarousel() {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          CarouselSlider.builder(
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
        ],
      );
    }

    buildNormalCarousel() {
      return Container(
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

    buildDismissButton() {
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

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        widget.fullscreen ? buildFullscreenCarousel() : buildNormalCarousel(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: widget.fullscreen ? buildDismissButton() : SizedBox.shrink(),
        ),
        Positioned(
          bottom: widget.small ? 4.0 : 8.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(20)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                if(widget.images.length > 1) {
                  return Container(
                    width: widget.small ? 4.0 : 8.0,
                    height: widget.small ? 4.0 : 8.0,
                    margin: EdgeInsets.symmetric(vertical: widget.small ? 2.0 : 4.0, horizontal: widget.small ? 2.0 : 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == index ? widget.color : widget.color.withOpacity(0.2),
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
            ),
          ),
        )
      ],
    );
  }
}