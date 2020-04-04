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
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: CachedNetworkImage(
        imageUrl: imageURL,
        imageBuilder: (context, imageProvider) => Container(
          color: Colors.black12,
          height: MediaQuery.of(context).size.height * Constants.postTileScaleFactor,
          width: fullscreen ? null : MediaQuery.of(context).size.width,
          child: Image(
            image: imageProvider, 
            fit: fullscreen ? BoxFit.contain : BoxFit.cover,
          ),
        ),
        placeholder: (context, url) => Container(
          height: MediaQuery.of(context).size.height * Constants.postTileScaleFactor,
          width: fullscreen ? null : MediaQuery.of(context).size.width,
          child: fullscreen ? Center(child: CircularProgressIndicator()) : Loading(color: color),
        ),
        errorWidget: (context, url, error) => Container(
          height: MediaQuery.of(context).size.height * Constants.postTileScaleFactor,
          width: fullscreen ? null : MediaQuery.of(context).size.width,
          child: Center(child: CustomAwesomeIcon(icon: FontAwesomeIcons.exclamationCircle)),
        ),
      ),
    );
  }
}