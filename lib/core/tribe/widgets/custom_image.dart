import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/loading.dart';

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
    _buildImage(ImageProvider imageProvider) {
      return Container(
        color: Colors.white,
        width: fullscreen ? null : MediaQuery.of(context).size.width,
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 10.0,
          scaleEnabled: fullscreen,
          child: Image(
            image: imageProvider,
            width: MediaQuery.of(context).size.width,
            fit: fullscreen ? BoxFit.fitWidth : BoxFit.cover,
          ),
        ),
      );
    }

    _buildPlaceholder() {
      return Container(
        width: fullscreen ? null : MediaQuery.of(context).size.width,
        child: fullscreen
            ? Center(child: Loading(color: color, size: 100))
            : Loading(color: color),
      );
    }

    _buildError() {
      return Container(
        width: fullscreen ? null : MediaQuery.of(context).size.width,
        child: Center(
          child: CustomAwesomeIcon(
            icon: FontAwesomeIcons.exclamationCircle,
            color: color.withOpacity(0.5),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: CachedNetworkImage(
        imageUrl: imageURL,
        imageBuilder: (context, imageProvider) => _buildImage(imageProvider),
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildError(),
      ),
    );
  }
}
