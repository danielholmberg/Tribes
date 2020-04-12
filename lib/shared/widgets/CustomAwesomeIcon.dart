import 'package:flutter/material.dart';
import 'package:tribes/shared/constants.dart' as Constants;

// FontAwesome center icon workaround. See more here: https://github.com/flutter/flutter/issues/24054
class CustomAwesomeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool inverse;
  final List<Shadow> shadows;
  final EdgeInsets padding;
  final double strokeWidth;
  CustomAwesomeIcon({
    @required this.icon,
    this.color = Constants.buttonIconColor,
    this.size = Constants.defaultIconSize,
    this.inverse = false,
    this.shadows,
    this.padding = EdgeInsets.zero,
    this.strokeWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Stack(
        children: <Widget>[
          Visibility(
            visible: strokeWidth != 0.0,
            child: Text(
              String.fromCharCode(icon.codePoint),
              style: TextStyle(
                fontSize: size,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..color = inverse ? Colors.black : Colors.white,
                fontFamily: icon.fontFamily,
                package: icon.fontPackage,
                shadows: shadows,
              ),
            ),
          ),
          Text(
            String.fromCharCode(icon.codePoint),
            style: TextStyle(
              color: inverse ? Constants.primaryColor : color,
              fontSize: size,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              shadows: shadows,
            ),
          ),
        ],
      ),
    );
  }
}