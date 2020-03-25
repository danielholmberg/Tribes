import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class CustomImage extends StatelessWidget {
  final String imageURL;
  final Color color;
  final bool small;
  final bool fullscreen;
  final double width;
  final double height;
  final EdgeInsets margin;
  CustomImage({
    @required this.imageURL,
    this.color = Constants.primaryColor,
    this.small = false,
    this.fullscreen = false,
    this.width, 
    this.height,
    this.margin = const EdgeInsets.all(5.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: CachedNetworkImage(
          imageUrl: imageURL,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.6),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              border: fullscreen ? null : Border.all(width: small ? 2.0 : 4.0, color: color.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: Offset(0, 0),
                ),
              ]
            ),
            height: MediaQuery.of(context).size.height * Constants.postTileScaleFactor,
            width: fullscreen ? null : MediaQuery.of(context).size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: Image(
                image: imageProvider, 
                fit: fullscreen ? BoxFit.contain : BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) => Container(
            height: MediaQuery.of(context).size.height * (fullscreen ? 1.0 : Constants.postTileScaleFactor),
            width: fullscreen ? null : MediaQuery.of(context).size.width,
            child: Loading(color: color),
          ),
          errorWidget: (context, url, error) => Container(
            height: MediaQuery.of(context).size.height * (fullscreen ? 1.0 : Constants.postTileScaleFactor),
            width: fullscreen ? null : MediaQuery.of(context).size.width,
            child: Center(child: CustomAwesomeIcon(icon: FontAwesomeIcons.exclamationCircle)),
          ),
        ),
      ),
    );
  }
}