import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final Color color;
  final bool small;
  ImageCarousel({
    @required this.images,
    this.color = Constants.primaryColor,
    this.small = false,
  });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {

  int _current = 0;
  PhotoViewController controller;

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    controller = PhotoViewController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: CarouselSlider.builder(
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.6),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        border: Border.all(width: widget.small ? 2.0 : 4.0, color: widget.color.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.4),
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                        ]
                      ),
                      height: MediaQuery.of(context).size.height * Constants.postTileScaleFactor,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        child: PhotoView(
                          imageProvider: imageProvider,
                          controller: controller,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Container(
                      height: MediaQuery.of(context).size.height * Constants.postTileScaleFactor,
                      width: MediaQuery.of(context).size.width,
                      child: Loading(color: widget.color),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: MediaQuery.of(context).size.height * Constants.postTileScaleFactor,
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: CustomAwesomeIcon(icon: FontAwesomeIcons.exclamationCircle)),
                    ),
                  ),
                ),
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) {
            return Container(
              width: widget.small ? 4.0 : 8.0,
              height: widget.small ? 4.0 : 8.0,
              margin: EdgeInsets.symmetric(vertical: widget.small ? 3.0 : 6.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == index ? widget.color : Color.fromRGBO(0, 0, 0, 0.2)
              ),
            );
          }),
        )
      ],
    );
  }
}